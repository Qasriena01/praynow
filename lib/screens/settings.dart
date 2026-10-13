import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool adhanEnabled = true;
  String selectedLocation = 'Getting location...';
  double? savedLatitude;
  double? savedLongitude;
  bool isLoadingCurrentLocation = false;

  final String googleApiKey = 'AIzaSyBoZ83Xrsw0vo8U1JHSYhaTB4AAnpnZBY4';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        notificationsEnabled = prefs.getBool('notifications') ?? true;
        adhanEnabled = prefs.getBool('adhan') ?? true;
        selectedLocation = prefs.getString('location') ?? 'Shah Alam, Selangor';
        savedLatitude = prefs.getDouble('latitude');
        savedLongitude = prefs.getDouble('longitude');
      });
    }
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }

  Future<void> _saveLocationWithCoordinates(String location, double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('location', location);
    await prefs.setDouble('latitude', lat);
    await prefs.setDouble('longitude', lng);
    
    if (mounted) {
      setState(() {
        selectedLocation = location;
        savedLatitude = lat;
        savedLongitude = lng;
      });
    }
  }

  Future<void> _getCurrentLocation(BuildContext dialogContext) async {
    setState(() {
      isLoadingCurrentLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = '';
        
        if (place.locality != null && place.locality!.isNotEmpty) {
          address = place.locality!;
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          address += address.isEmpty ? place.administrativeArea! : ', ${place.administrativeArea!}';
        }
        if (place.country != null && place.country!.isNotEmpty) {
          address += address.isEmpty ? place.country! : ', ${place.country!}';
        }

        if (address.isEmpty) {
          address = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
        }

        await _saveLocationWithCoordinates(
          address,
          position.latitude,
          position.longitude,
        );

        if (mounted && dialogContext.mounted) {
          Navigator.pop(dialogContext);
          _showSnackBar('📍 Location updated to: $address');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('❌ Error getting location: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingCurrentLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F766E),
                      Color(0xFF14B8A6),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Customize your prayer settings',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Settings Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Prayer Settings',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 14),
                    
                    // Notifications
                    _buildSettingCard(
                      icon: Icons.notifications,
                      title: 'Prayer Notifications',
                      subtitle: notificationsEnabled ? 'Enabled' : 'Disabled',
                      color: const Color(0xFF14B8A6),
                      trailing: Switch(
                        value: notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            notificationsEnabled = value;
                          });
                          _saveSetting('notifications', value);
                          _showSnackBar(
                            value
                                ? 'Prayer notifications enabled'
                                : 'Prayer notifications disabled',
                          );
                        },
                        activeThumbColor: const Color(0xFF14B8A6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Adhan Sound
                    _buildSettingCard(
                      icon: Icons.volume_up,
                      title: 'Adhan Sound',
                      subtitle: adhanEnabled ? 'Enabled' : 'Disabled',
                      color: const Color(0xFF0F766E),
                      trailing: Switch(
                        value: adhanEnabled,
                        onChanged: (value) {
                          setState(() {
                            adhanEnabled = value;
                          });
                          _saveSetting('adhan', value);
                          _showSnackBar(
                            value ? 'Adhan sound enabled' : 'Adhan sound disabled',
                          );
                        },
                        activeThumbColor: const Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Location
                    _buildSettingCard(
                      icon: Icons.location_on,
                      title: 'Location',
                      subtitle: savedLatitude != null && savedLongitude != null
                          ? '$selectedLocation\n📍 ${savedLatitude!.toStringAsFixed(4)}, ${savedLongitude!.toStringAsFixed(4)}'
                          : selectedLocation,
                      color: const Color(0xFF14B8A6),
                      onTap: () {
                        _showLocationDialog();
                      },
                    ),
                    const SizedBox(height: 10),
                    
                    // Calculation Method
                    _buildSettingCard(
                      icon: Icons.calculate,
                      title: 'Calculation Method',
                      subtitle: 'JAKIM (Malaysia)',
                      color: const Color(0xFF0F766E),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F766E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Fixed',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F766E),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Logout Button - FIXED
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleLogout(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ??
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showLocationDialog() {
    final locationController = TextEditingController();
    bool isSearching = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF14B8A6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFF14B8A6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Change Location',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Use Current Location Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoadingCurrentLocation
                          ? null
                          : () => _getCurrentLocation(dialogContext),
                      icon: isLoadingCurrentLocation
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.my_location, size: 18),
                      label: Text(
                        isLoadingCurrentLocation
                            ? 'Getting Location...'
                            : 'Use Current Location',
                        style: const TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14B8A6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Divider with "OR"
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Google Places Autocomplete
                  GooglePlaceAutoCompleteTextField(
                    textEditingController: locationController,
                    googleAPIKey: googleApiKey,
                    inputDecoration: InputDecoration(
                      labelText: 'Search location',
                      hintText: 'Type city or area name...',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF14B8A6),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    debounceTime: 400,
                    countries: const ["my"],
                    isLatLngRequired: true,
                    getPlaceDetailWithLatLng: (prediction) async {
                      setDialogState(() => isSearching = true);
                      
                      final lat = double.tryParse(prediction.lat ?? '0') ?? 0.0;
                      final lng = double.tryParse(prediction.lng ?? '0') ?? 0.0;
                      final location = prediction.description ?? '';
                      
                      if (lat != 0.0 && lng != 0.0) {
                        await _saveLocationWithCoordinates(location, lat, lng);
                        
                        if (context.mounted) {
                          Navigator.pop(dialogContext);
                          _showSnackBar('📍 Location updated to $location');
                        }
                      }
                      
                      setDialogState(() => isSearching = false);
                    },
                    itemClick: (prediction) {
                      locationController.text = prediction.description ?? '';
                    },
                    seperatedBuilder: const Divider(height: 1),
                    itemBuilder: (context, index, prediction) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 18,
                              color: Color(0xFF14B8A6),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                prediction.description ?? "",
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    isCrossBtnShown: true,
                  ),
                  const SizedBox(height: 16),
                  
                  // Info box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Search Malaysian locations or use GPS',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (isSearching)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF14B8A6),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ FIXED LOGOUT FUNCTION
  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red, size: 24),
            SizedBox(width: 10),
            Text('Logout', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Logout', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );

    // If user confirmed logout
    if (shouldLogout == true && context.mounted) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        );

        // Sign out from Firebase
        await FirebaseAuth.instance.signOut();

        // Clear shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Close loading dialog and navigate to login
        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          
          // Navigate to login and remove all previous routes
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        // Close loading dialog if it's showing
        if (context.mounted) {
          Navigator.of(context).pop();
        }
        
        // Show error message
        if (mounted) {
          _showSnackBar('❌ Error logging out: ${e.toString()}');
        }
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontSize: 13)),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF1F2937),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}