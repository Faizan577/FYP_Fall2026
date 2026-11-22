import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/land_offer.dart';

class LandService {
  static const _landOffersKey = 'baghbani.land_offers';

  static final List<LandOffer> _sampleOffers = [
    LandOffer(
      id: 'land_1',
      userId: 'usr_sample_1',
      ownerName: 'Chaudhry Riaz',
      title: '25 Acres Agricultural Land for Wheat & Rice',
      location: 'Sheikhupura Road, Punjab',
      acreage: '25 Acres',
      waterSource: 'Canal + Solar Tube-well',
      partnershipType: 'Seasonal Crop Sharing',
      description:
          'Fertile alluvial soil with continuous canal water access. Looking for experienced crop manager for upcoming Rabi and Kharif seasons. Laser leveled last month.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    LandOffer(
      id: 'land_2',
      userId: 'usr_sample_2',
      ownerName: 'Mian Aslam',
      title: '15 Acres Orchard & Crop Land',
      location: 'Khanewal, Punjab',
      acreage: '15 Acres',
      waterSource: 'Drip System Installed',
      partnershipType: 'Full Management Contract',
      description:
          '10 acres vacant for cash crops, 5 acres young citrus orchard. Drip lines already laid. Seeking dedicated farm manager or experienced team.',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  Future<List<LandOffer>> getLandOffers() async {
    final prefs = await SharedPreferences.getInstance();
    final customRaw = prefs.getStringList(_landOffersKey) ?? [];
    final customOffers = customRaw.map((e) {
      return LandOffer.fromJson(jsonDecode(e) as Map<String, dynamic>);
    }).toList();

    return [...customOffers, ..._sampleOffers];
  }

  Future<void> submitLandOffer(LandOffer offer) async {
    final prefs = await SharedPreferences.getInstance();
    final customRaw = prefs.getStringList(_landOffersKey) ?? [];
    customRaw.insert(0, jsonEncode(offer.toJson()));
    await prefs.setStringList(_landOffersKey, customRaw);
  }
}
