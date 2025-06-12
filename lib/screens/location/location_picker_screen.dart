import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:efishery/widgets/custom_appbar.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  String _address = '';
  bool _isLoading = false;

  // Default center to Indonesia
  final LatLng _defaultCenter = const LatLng(-2.548926, 118.014863);

  // Custom FAB position (in pixels from edges)
  final double _fabRight = 32; // Jarak dari kanan layar
  final double _fabBottom = 64; // Jarak dari bawah layar

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _mapController.move(_selectedLocation!, 15);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onTapMap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
      _address =
          'Lat: ${point.latitude.toStringAsFixed(6)}, '
          'Long: ${point.longitude.toStringAsFixed(6)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Pilih Lokasi',
        showCheckButton: _selectedLocation != null,
        onCheckPressed:
            _selectedLocation != null
                ? () {
                  Navigator.pop(context, {
                    'latitude': _selectedLocation!.latitude,
                    'longitude': _selectedLocation!.longitude,
                    'address': _address,
                  });
                }
                : null,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation ?? _defaultCenter,
              initialZoom: 5.0,
              onTap: _onTapMap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          if (_isLoading) const Center(child: CircularProgressIndicator()),

          if (_selectedLocation != null)
            Positioned(
              bottom: 48,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lokasi Terpilih:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(_address),
                    ],
                  ),
                ),
              ),
            ),

          // Custom Positioned FloatingActionButton
          Positioned(
            right: _fabRight,
            bottom: _fabBottom,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
