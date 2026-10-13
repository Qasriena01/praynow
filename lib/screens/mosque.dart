// FILE: lib/mosques_page.dart
// Improved version with better Google Maps integration

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class MosquesPage extends StatefulWidget {
  const MosquesPage({super.key});

  @override
  State<MosquesPage> createState() => _MosquesPageState();
}

class _MosquesPageState extends State<MosquesPage> {
  List<Map<String, dynamic>> mosques = [];
  bool isLoading = true;
  Position? currentPosition;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.denied && 
          permission != LocationPermission.deniedForever) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        
        if (!mounted) return;
        
        setState(() {
          currentPosition = position;
        });
        
        await _fetchNearbyMosques(position.latitude, position.longitude);
      } else {
        if (!mounted) return;
        
        setState(() {
          errorMessage = 'Location permission denied';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        errorMessage = 'Error getting location: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchNearbyMosques(double lat, double lon) async {
    try {
      // Using Overpass API to find mosques
      final query = '''
        [out:json];
        (
          node["amenity"="place_of_worship"]["religion"="muslim"](around:5000,$lat,$lon);
          way["amenity"="place_of_worship"]["religion"="muslim"](around:5000,$lat,$lon);
        );
        out center;
      ''';

      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        body: query,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> fetchedMosques = [];

        for (var element in data['elements']) {
          double mosqueLat = element['lat'] ?? element['center']?['lat'] ?? 0;
          double mosqueLon = element['lon'] ?? element['center']?['lon'] ?? 0;
          
          if (mosqueLat == 0 || mosqueLon == 0) continue;

          double distance = Geolocator.distanceBetween(
            lat,
            lon,
            mosqueLat,
            mosqueLon,
          );

          fetchedMosques.add({
            'name': element['tags']?['name'] ?? 'Unnamed Mosque',
            'address': element['tags']?['addr:full'] ?? 
                      element['tags']?['addr:street'] ?? 
                      'Address not available',
            'latitude': mosqueLat,
            'longitude': mosqueLon,
            'distance': distance,
            'phone': element['tags']?['phone'] ?? '',
            'website': element['tags']?['website'] ?? '',
          });
        }

        // Sort by distance
        fetchedMosques.sort((a, b) => 
          (a['distance'] as double).compareTo(b['distance'] as double)
        );

        if (!mounted) return;

        setState(() {
          mosques = fetchedMosques.take(20).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        errorMessage = 'Error fetching mosques: $e';
        isLoading = false;
      });
    }
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  // ✅ IMPROVED: Open Google Maps with mosque name for better search
  Future<void> _openMaps(double lat, double lon, String name) async {
    // Method 1: Search by name and location (RECOMMENDED)
    // This will show the mosque with its name in Google Maps
    final encodedName = Uri.encodeComponent(name);
    final url = 'https://www.google.com/maps/search/?api=1&query=$encodedName+near+$lat,$lon';
    
    // Method 2: Direct location (fallback)
    // final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon';
    
    // Method 3: Place a pin with label
    // final url = 'geo:$lat,$lon?q=$lat,$lon($encodedName)';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        // Fallback to simple coordinate search if name search fails
        final fallbackUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
        if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
          await launchUrl(Uri.parse(fallbackUrl), mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      print('Error opening maps: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open maps: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ✅ NEW: Open Google Maps for navigation (turn-by-turn directions)
  Future<void> _getDirections(double lat, double lon, String name) async {
    // This will open turn-by-turn navigation in Google Maps
    final encodedName = Uri.encodeComponent(name);
    
    // For navigation from current location to mosque
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=driving';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error opening directions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open directions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ✅ NEW: Show detailed mosque information
  void _showMosqueDetails(Map<String, dynamic> mosque) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Mosque Icon and Name
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.mosque,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mosque['name'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDistance(mosque['distance']),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Address
                  _buildDetailRow(
                    icon: Icons.location_on,
                    title: 'Address',
                    content: mosque['address'],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Coordinates
                  _buildDetailRow(
                    icon: Icons.my_location,
                    title: 'Coordinates',
                    content: '${mosque['latitude'].toStringAsFixed(6)}, ${mosque['longitude'].toStringAsFixed(6)}',
                  ),
                  
                  // Phone (if available)
                  if (mosque['phone'].isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      icon: Icons.phone,
                      title: 'Phone',
                      content: mosque['phone'],
                      onTap: () async {
                        final url = 'tel:${mosque['phone']}';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                        }
                      },
                    ),
                  ],
                  
                  // Website (if available)
                  if (mosque['website'].isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      icon: Icons.language,
                      title: 'Website',
                      content: mosque['website'],
                      onTap: () async {
                        if (await canLaunchUrl(Uri.parse(mosque['website']))) {
                          await launchUrl(
                            Uri.parse(mosque['website']),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _getDirections(
                              mosque['latitude'],
                              mosque['longitude'],
                              mosque['name'],
                            );
                          },
                          icon: const Icon(Icons.directions),
                          label: const Text('Directions'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _openMaps(
                              mosque['latitude'],
                              mosque['longitude'],
                              mosque['name'],
                            );
                          },
                          icon: const Icon(Icons.map),
                          label: const Text('View on Map'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF8B5CF6),
                            side: const BorderSide(color: Color(0xFF8B5CF6)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String content,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF8B5CF6),
        title: const Text(
          'Nearby Mosques',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
                errorMessage = '';
              });
              _initializeLocation();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                              errorMessage = '';
                            });
                            _initializeLocation();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF8B5CF6),
                            Color(0xFF7C3AED),
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.mosque,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${mosques.length} Mosques Found',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Within 5 km radius',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Mosques List
                    Expanded(
                      child: mosques.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.mosque,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No mosques found nearby',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () async {
                                if (currentPosition != null) {
                                  await _fetchNearbyMosques(
                                    currentPosition!.latitude,
                                    currentPosition!.longitude,
                                  );
                                }
                              },
                              child: ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: mosques.length,
                                itemBuilder: (context, index) {
                                  return _buildMosqueCard(mosques[index], index + 1);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildMosqueCard(Map<String, dynamic> mosque, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rank Badge
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      rank.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Mosque Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mosque['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Color(0xFF8B5CF6),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              mosque['address'],
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.directions_walk,
                                  size: 14,
                                  color: Color(0xFF8B5CF6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDistance(mosque['distance']),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8B5CF6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (mosque['phone'].isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.phone,
                              size: 16,
                              color: Colors.grey.shade400,
                            ),
                          ],
                          if (mosque['website'].isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.language,
                              size: 16,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _getDirections(
                      mosque['latitude'],
                      mosque['longitude'],
                      mosque['name'],
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions,
                            color: Color(0xFF8B5CF6),
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Directions',
                            style: TextStyle(
                              color: Color(0xFF8B5CF6),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.shade200,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _showMosqueDetails(mosque),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'More Info',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}