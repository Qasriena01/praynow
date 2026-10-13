import 'package:flutter/material.dart';

class NamesOfAllahPage extends StatelessWidget {
  const NamesOfAllahPage({super.key});

  @override
  Widget build(BuildContext context) {
    final names = [
      {
        'arabic': 'ٱلرَّحْمَـٰنُ',
        'transliteration': 'Ar-Rahman',
        'meaning': 'The Most Compassionate',
        'description': 'The One whose mercy encompasses all of creation'
      },
      {
        'arabic': 'ٱلرَّحِيمُ',
        'transliteration': 'Ar-Rahim',
        'meaning': 'The Most Merciful',
        'description': 'The One who shows continuous mercy especially to believers'
      },
      {
        'arabic': 'ٱلْمَلِكُ',
        'transliteration': 'Al-Malik',
        'meaning': 'The King',
        'description': 'The Sovereign Lord, Master of the Kingdom'
      },
      {
        'arabic': 'ٱلْقُدُّوسُ',
        'transliteration': 'Al-Quddus',
        'meaning': 'The Most Holy',
        'description': 'The Pure One, free from all imperfections'
      },
      {
        'arabic': 'ٱلسَّلَامُ',
        'transliteration': 'As-Salam',
        'meaning': 'The Source of Peace',
        'description': 'The One who is free from all defects and bestows peace'
      },
      {
        'arabic': 'ٱلْمُؤْمِنُ',
        'transliteration': 'Al-Mu\'min',
        'meaning': 'The Granter of Security',
        'description': 'The One who grants security and removes fear'
      },
      {
        'arabic': 'ٱلْمُهَيْمِنُ',
        'transliteration': 'Al-Muhaymin',
        'meaning': 'The Guardian',
        'description': 'The Overseer and Guardian of all creation'
      },
      {
        'arabic': 'ٱلْعَزِيزُ',
        'transliteration': 'Al-Aziz',
        'meaning': 'The Almighty',
        'description': 'The All-Powerful, The Invincible'
      },
      {
        'arabic': 'ٱلْجَبَّارُ',
        'transliteration': 'Al-Jabbar',
        'meaning': 'The Compeller',
        'description': 'The One who compels all creation to His will'
      },
      {
        'arabic': 'ٱلْمُتَكَبِّرُ',
        'transliteration': 'Al-Mutakabbir',
        'meaning': 'The Supreme',
        'description': 'The One who is supremely great'
      },
      {
        'arabic': 'ٱلْخَـٰلِقُ',
        'transliteration': 'Al-Khaliq',
        'meaning': 'The Creator',
        'description': 'The One who creates from nothing'
      },
      {
        'arabic': 'ٱلْبَارِئُ',
        'transliteration': 'Al-Bari\'',
        'meaning': 'The Evolver',
        'description': 'The Originator who fashions all creation'
      },
      {
        'arabic': 'ٱلْمُصَوِّرُ',
        'transliteration': 'Al-Musawwir',
        'meaning': 'The Fashioner',
        'description': 'The One who shapes all creation in perfect forms'
      },
      {
        'arabic': 'ٱلْغَفَّارُ',
        'transliteration': 'Al-Ghaffar',
        'meaning': 'The Oft-Forgiving',
        'description': 'The One who forgives again and again'
      },
      {
        'arabic': 'ٱلْقَهَّارُ',
        'transliteration': 'Al-Qahhar',
        'meaning': 'The Subduer',
        'description': 'The Dominant One who has power over all things'
      },
      {
        'arabic': 'ٱلْوَهَّابُ',
        'transliteration': 'Al-Wahhab',
        'meaning': 'The Bestower',
        'description': 'The One who gives endlessly'
      },
      {
        'arabic': 'ٱلرَّزَّاقُ',
        'transliteration': 'Ar-Razzaq',
        'meaning': 'The Provider',
        'description': 'The One who provides sustenance to all creation'
      },
      {
        'arabic': 'ٱلْفَتَّاحُ',
        'transliteration': 'Al-Fattah',
        'meaning': 'The Opener',
        'description': 'The One who opens all doors and grants victory'
      },
      {
        'arabic': 'ٱلْعَلِيمُ',
        'transliteration': 'Al-Alim',
        'meaning': 'The All-Knowing',
        'description': 'The One who knows everything'
      },
      {
        'arabic': 'ٱلْقَابِضُ',
        'transliteration': 'Al-Qabid',
        'meaning': 'The Withholder',
        'description': 'The One who restricts and constricts'
      },
      {
        'arabic': 'ٱلْبَاسِطُ',
        'transliteration': 'Al-Basit',
        'meaning': 'The Expander',
        'description': 'The One who expands and grants abundance'
      },
      {
        'arabic': 'ٱلْخَافِضُ',
        'transliteration': 'Al-Khafid',
        'meaning': 'The Abaser',
        'description': 'The One who humbles'
      },
      {
        'arabic': 'ٱلرَّافِعُ',
        'transliteration': 'Ar-Rafi\'',
        'meaning': 'The Exalter',
        'description': 'The One who raises and elevates'
      },
      {
        'arabic': 'ٱلْمُعِزُّ',
        'transliteration': 'Al-Mu\'izz',
        'meaning': 'The Honourer',
        'description': 'The One who bestows honor'
      },
      {
        'arabic': 'ٱلْمُذِلُّ',
        'transliteration': 'Al-Mudhill',
        'meaning': 'The Dishonourer',
        'description': 'The One who humiliates'
      },
      {
        'arabic': 'ٱلسَّمِيعُ',
        'transliteration': 'As-Sami\'',
        'meaning': 'The All-Hearing',
        'description': 'The One who hears all things'
      },
      {
        'arabic': 'ٱلْبَصِيرُ',
        'transliteration': 'Al-Basir',
        'meaning': 'The All-Seeing',
        'description': 'The One who sees all things'
      },
      {
        'arabic': 'ٱلْحَكَمُ',
        'transliteration': 'Al-Hakam',
        'meaning': 'The Judge',
        'description': 'The One who judges with perfect justice'
      },
      {
        'arabic': 'ٱلْعَدْلُ',
        'transliteration': 'Al-Adl',
        'meaning': 'The Just',
        'description': 'The Utterly Just'
      },
      {
        'arabic': 'ٱللَّطِيفُ',
        'transliteration': 'Al-Latif',
        'meaning': 'The Subtle One',
        'description': 'The Most Gentle, The Most Courteous'
      },
      {
        'arabic': 'ٱلْخَبِيرُ',
        'transliteration': 'Al-Khabir',
        'meaning': 'The All-Aware',
        'description': 'The One who is aware of all things'
      },
      {
        'arabic': 'ٱلْحَلِيمُ',
        'transliteration': 'Al-Halim',
        'meaning': 'The Forbearing',
        'description': 'The Most Clement and Forebearing'
      },
      {
        'arabic': 'ٱلْعَظِيمُ',
        'transliteration': 'Al-Azim',
        'meaning': 'The Magnificent',
        'description': 'The Supreme, The Magnificent'
      },
      {
        'arabic': 'ٱلْغَفُورُ',
        'transliteration': 'Al-Ghafur',
        'meaning': 'The All-Forgiving',
        'description': 'The Great Forgiver'
      },
      {
        'arabic': 'ٱلشَّكُورُ',
        'transliteration': 'Ash-Shakur',
        'meaning': 'The Appreciative',
        'description': 'The One who appreciates and rewards good deeds'
      },
      {
        'arabic': 'ٱلْعَلِيُّ',
        'transliteration': 'Al-Aliyy',
        'meaning': 'The Most High',
        'description': 'The Exalted, The Most High'
      },
      {
        'arabic': 'ٱلْكَبِيرُ',
        'transliteration': 'Al-Kabir',
        'meaning': 'The Most Great',
        'description': 'The Greatest, The Most Grand'
      },
      {
        'arabic': 'ٱلْحَفِيظُ',
        'transliteration': 'Al-Hafiz',
        'meaning': 'The Preserver',
        'description': 'The Guardian, The Preserver'
      },
      {
        'arabic': 'ٱلْمُقِيتُ',
        'transliteration': 'Al-Muqit',
        'meaning': 'The Sustainer',
        'description': 'The Nourisher, The Sustainer'
      },
      {
        'arabic': 'ٱلْحَسِيبُ',
        'transliteration': 'Al-Hasib',
        'meaning': 'The Reckoner',
        'description': 'The One who takes account'
      },
      {
        'arabic': 'ٱلْجَلِيلُ',
        'transliteration': 'Al-Jalil',
        'meaning': 'The Majestic',
        'description': 'The Sublime One, The Majestic'
      },
      {
        'arabic': 'ٱلْكَرِيمُ',
        'transliteration': 'Al-Karim',
        'meaning': 'The Generous',
        'description': 'The Most Generous, The Most Esteemed'
      },
      {
        'arabic': 'ٱلرَّقِيبُ',
        'transliteration': 'Ar-Raqib',
        'meaning': 'The Watchful',
        'description': 'The Ever-Watchful'
      },
      {
        'arabic': 'ٱلْمُجِيبُ',
        'transliteration': 'Al-Mujib',
        'meaning': 'The Responsive',
        'description': 'The One who responds to prayers'
      },
      {
        'arabic': 'ٱلْوَاسِعُ',
        'transliteration': 'Al-Wasi\'',
        'meaning': 'The All-Encompassing',
        'description': 'The Boundless, The Vast'
      },
      {
        'arabic': 'ٱلْحَكِيمُ',
        'transliteration': 'Al-Hakim',
        'meaning': 'The Wise',
        'description': 'The Perfectly Wise'
      },
      {
        'arabic': 'ٱلْوَدُودُ',
        'transliteration': 'Al-Wadud',
        'meaning': 'The Loving',
        'description': 'The Most Loving'
      },
      {
        'arabic': 'ٱلْمَجِيدُ',
        'transliteration': 'Al-Majid',
        'meaning': 'The Glorious',
        'description': 'The All-Glorious, The Most Honorable'
      },
      {
        'arabic': 'ٱلْبَاعِثُ',
        'transliteration': 'Al-Ba\'ith',
        'meaning': 'The Resurrector',
        'description': 'The Raiser of the Dead'
      },
      {
        'arabic': 'ٱلشَّهِيدُ',
        'transliteration': 'Ash-Shahid',
        'meaning': 'The Witness',
        'description': 'The All-Witnessing'
      },
      {
        'arabic': 'ٱلْحَقُّ',
        'transliteration': 'Al-Haqq',
        'meaning': 'The Truth',
        'description': 'The Absolute Truth'
      },
      {
        'arabic': 'ٱلْوَكِيلُ',
        'transliteration': 'Al-Wakil',
        'meaning': 'The Trustee',
        'description': 'The Ultimate Trustee, The Disposer of Affairs'
      },
      {
        'arabic': 'ٱلْقَوِيُّ',
        'transliteration': 'Al-Qawiyy',
        'meaning': 'The Strong',
        'description': 'The All-Strong, The Most Powerful'
      },
      {
        'arabic': 'ٱلْمَتِينُ',
        'transliteration': 'Al-Matin',
        'meaning': 'The Firm',
        'description': 'The Firm One, The Steadfast'
      },
      {
        'arabic': 'ٱلْوَلِيُّ',
        'transliteration': 'Al-Waliyy',
        'meaning': 'The Protecting Friend',
        'description': 'The Guardian, The Protecting Associate'
      },
      {
        'arabic': 'ٱلْحَمِيدُ',
        'transliteration': 'Al-Hamid',
        'meaning': 'The Praiseworthy',
        'description': 'The Praiseworthy, The Ever-Praised'
      },
      {
        'arabic': 'ٱلْمُحْصِي',
        'transliteration': 'Al-Muhsi',
        'meaning': 'The Reckoner',
        'description': 'The All-Enumerating, The Counter'
      },
      {
        'arabic': 'ٱلْمُبْدِئُ',
        'transliteration': 'Al-Mubdi\'',
        'meaning': 'The Originator',
        'description': 'The Originator, The Initiator'
      },
      {
        'arabic': 'ٱلْمُعِيدُ',
        'transliteration': 'Al-Mu\'id',
        'meaning': 'The Restorer',
        'description': 'The Restorer, The Reinstater'
      },
      {
        'arabic': 'ٱلْمُحْيِي',
        'transliteration': 'Al-Muhyi',
        'meaning': 'The Giver of Life',
        'description': 'The Giver of Life'
      },
      {
        'arabic': 'ٱلْمُمِيتُ',
        'transliteration': 'Al-Mumit',
        'meaning': 'The Bringer of Death',
        'description': 'The Destroyer, The Bringer of Death'
      },
      {
        'arabic': 'ٱلْحَيُّ',
        'transliteration': 'Al-Hayy',
        'meaning': 'The Ever-Living',
        'description': 'The Ever-Living, The Eternal'
      },
      {
        'arabic': 'ٱلْقَيُّومُ',
        'transliteration': 'Al-Qayyum',
        'meaning': 'The Self-Sustaining',
        'description': 'The Self-Subsisting, The Sustainer of All'
      },
      {
        'arabic': 'ٱلْوَاجِدُ',
        'transliteration': 'Al-Wajid',
        'meaning': 'The Finder',
        'description': 'The Perceiver, The Finder'
      },
      {
        'arabic': 'ٱلْمَاجِدُ',
        'transliteration': 'Al-Majid',
        'meaning': 'The Noble',
        'description': 'The Illustrious, The Magnificent'
      },
      {
        'arabic': 'ٱلْوَاحِدُ',
        'transliteration': 'Al-Wahid',
        'meaning': 'The One',
        'description': 'The Unique, The Only One'
      },
      {
        'arabic': 'ٱلْأَحَد',
        'transliteration': 'Al-Ahad',
        'meaning': 'The Unique',
        'description': 'The Indivisible, The One and Only'
      },
      {
        'arabic': 'ٱلصَّمَدُ',
        'transliteration': 'As-Samad',
        'meaning': 'The Eternal',
        'description': 'The Self-Sufficient, The Eternal Refuge'
      },
      {
        'arabic': 'ٱلْقَادِرُ',
        'transliteration': 'Al-Qadir',
        'meaning': 'The Capable',
        'description': 'The Omnipotent One, The Able'
      },
      {
        'arabic': 'ٱلْمُقْتَدِرُ',
        'transliteration': 'Al-Muqtadir',
        'meaning': 'The Powerful',
        'description': 'The All-Determiner, The Dominant'
      },
      {
        'arabic': 'ٱلْمُقَدِّمُ',
        'transliteration': 'Al-Muqaddim',
        'meaning': 'The Expediter',
        'description': 'The Promoter, The Expediter'
      },
      {
        'arabic': 'ٱلْمُؤَخِّرُ',
        'transliteration': 'Al-Mu\'akhkhir',
        'meaning': 'The Delayer',
        'description': 'The Delayer, The Retarder'
      },
      {
        'arabic': 'ٱلْأَوَّلُ',
        'transliteration': 'Al-Awwal',
        'meaning': 'The First',
        'description': 'The First, The Beginning'
      },
      {
        'arabic': 'ٱلْآخِرُ',
        'transliteration': 'Al-Akhir',
        'meaning': 'The Last',
        'description': 'The Last, The End'
      },
      {
        'arabic': 'ٱلظَّاهِرُ',
        'transliteration': 'Az-Zahir',
        'meaning': 'The Manifest',
        'description': 'The Manifest, The Evident'
      },
      {
        'arabic': 'ٱلْبَاطِنُ',
        'transliteration': 'Al-Batin',
        'meaning': 'The Hidden',
        'description': 'The Hidden, The Inner'
      },
      {
        'arabic': 'ٱلْوَالِي',
        'transliteration': 'Al-Wali',
        'meaning': 'The Governor',
        'description': 'The Patron, The Governor'
      },
      {
        'arabic': 'ٱلْمُتَعَالِي',
        'transliteration': 'Al-Muta\'ali',
        'meaning': 'The Supremely Exalted',
        'description': 'The Self-Exalted, The Most High'
      },
      {
        'arabic': 'ٱلْبَرُّ',
        'transliteration': 'Al-Barr',
        'meaning': 'The Source of Goodness',
        'description': 'The Most Kind, The Righteous'
      },
      {
        'arabic': 'ٱلتَّوَّابُ',
        'transliteration': 'At-Tawwab',
        'meaning': 'The Acceptor of Repentance',
        'description': 'The Ever-Pardoning, The Relenting'
      },
      {
        'arabic': 'ٱلْمُنْتَقِمُ',
        'transliteration': 'Al-Muntaqim',
        'meaning': 'The Avenger',
        'description': 'The Avenger, The Inflictor of Retribution'
      },
      {
        'arabic': 'ٱلْعَفُوُّ',
        'transliteration': 'Al-\'Afuww',
        'meaning': 'The Pardoner',
        'description': 'The Pardoner, The Effacer'
      },
      {
        'arabic': 'ٱلرَّؤُوفُ',
        'transliteration': 'Ar-Ra\'uf',
        'meaning': 'The Most Kind',
        'description': 'The Compassionate, The Most Kind'
      },
      {
        'arabic': 'مَالِكُ ٱلْمُلْكُ',
        'transliteration': 'Malik-al-Mulk',
        'meaning': 'The Owner of Sovereignty',
        'description': 'The Eternal Possessor of Sovereignty'
      },
      {
        'arabic': 'ذُو ٱلْجَلَالِ وَٱلْإِكْرَامُ',
        'transliteration': 'Dhul-Jalali wal-Ikram',
        'meaning': 'Lord of Majesty and Bounty',
        'description': 'The Possessor of Glory and Honor'
      },
      {
        'arabic': 'ٱلْمُقْسِطُ',
        'transliteration': 'Al-Muqsit',
        'meaning': 'The Equitable',
        'description': 'The Just, The Equitable'
      },
      {
        'arabic': 'ٱلْجَامِعُ',
        'transliteration': 'Al-Jami\'',
        'meaning': 'The Gatherer',
        'description': 'The Assembler, The Gatherer'
      },
      {
        'arabic': 'ٱلْغَنِيُّ',
        'transliteration': 'Al-Ghaniyy',
        'meaning': 'The Self-Sufficient',
        'description': 'The Rich, The Independent'
      },
      {
        'arabic': 'ٱلْمُغْنِي',
        'transliteration': 'Al-Mughni',
        'meaning': 'The Enricher',
        'description': 'The Enricher, The Emancipator'
      },
      {
        'arabic': 'ٱلْمَانِعُ',
        'transliteration': 'Al-Mani\'',
        'meaning': 'The Preventer',
        'description': 'The Preventer of Harm, The Withholder'
      },
      {
        'arabic': 'ٱلضَّارُ',
        'transliteration': 'Ad-Darr',
        'meaning': 'The Distresser',
        'description': 'The Creator of Harm'
      },
      {
        'arabic': 'ٱلنَّافِعُ',
        'transliteration': 'An-Nafi\'',
        'meaning': 'The Benefactor',
        'description': 'The Propitious, The Beneficial'
      },
      {
        'arabic': 'ٱلنُّورُ',
        'transliteration': 'An-Nur',
        'meaning': 'The Light',
        'description': 'The Light, The Illuminator'
      },
      {
        'arabic': 'ٱلْهَادِي',
        'transliteration': 'Al-Hadi',
        'meaning': 'The Guide',
        'description': 'The Guide to the Right Path'
      },
      {
        'arabic': 'ٱلْبَدِيعُ',
        'transliteration': 'Al-Badi\'',
        'meaning': 'The Incomparable',
        'description': 'The Originator, The Unique'
      },
      {
        'arabic': 'ٱلْبَاقِي',
        'transliteration': 'Al-Baqi',
        'meaning': 'The Everlasting',
        'description': 'The Eternal, The Everlasting'
      },
      {
        'arabic': 'ٱلْوَارِثُ',
        'transliteration': 'Al-Warith',
        'meaning': 'The Inheritor',
        'description': 'The Supreme Inheritor'
      },
      {
        'arabic': 'ٱلرَّشِيدُ',
        'transliteration': 'Ar-Rashid',
        'meaning': 'The Guide to the Right Path',
        'description': 'The Righteous Teacher, The Guide'
      },
      {
        'arabic': 'ٱلصَّبُورُ',
        'transliteration': 'As-Sabur',
        'meaning': 'The Patient',
        'description': 'The Timeless, The Patient'
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFFEF4444),
            automaticallyImplyLeading: true,
            actions: const [],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true, // ✅ Added this to center the title
              title: const Text(
                '99 Names of Allah',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFEF4444),
                      Color(0xFFDC2626),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFEF4444).withOpacity(0.1),
                      const Color(0xFFDC2626).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.auto_stories,
                      color: Color(0xFFEF4444),
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'الأسماء الحسنى - Al-Asma ul-Husna',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final name = names[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Number Badge
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFEF4444),
                                Color(0xFFDC2626),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEF4444).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Name Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      name['transliteration'].toString(),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFEF4444),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    name['arabic'].toString(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                name['meaning'].toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                name['description'].toString(),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: names.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}