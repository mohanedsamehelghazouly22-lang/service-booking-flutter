import 'package:flutter/foundation.dart';
import '../models/service.dart';
import '../models/location.dart';
import '../models/availability_slot.dart';

/// Holds the in-progress Service -> Location -> Date -> Slot selection.
/// Guests can build this up freely; only the final "confirm booking" tap
/// requires auth. Because this lives above the navigator in the widget
/// tree, the selections survive the sign-in interruption untouched.
class BookingFlowProvider extends ChangeNotifier {
  ServiceModel? service;
  LocationModel? location;
  DateTime? date;
  AvailabilitySlot? slot;

  /// Set true right before redirecting to sign-in, so the app knows to
  /// jump straight back into the confirm screen once auth completes.
  bool resumeAfterAuth = false;

  void selectService(ServiceModel s) {
    service = s;
    location = null;
    date = null;
    slot = null;
    notifyListeners();
  }

  void selectLocation(LocationModel l) {
    location = l;
    date = null;
    slot = null;
    notifyListeners();
  }

  void selectDate(DateTime d) {
    date = d;
    slot = null;
    notifyListeners();
  }

  void selectSlot(AvailabilitySlot s) {
    slot = s;
    notifyListeners();
  }

  bool get isReadyToBook => service != null && location != null && date != null && slot != null;

  void reset() {
    service = null;
    location = null;
    date = null;
    slot = null;
    resumeAfterAuth = false;
    notifyListeners();
  }
}
