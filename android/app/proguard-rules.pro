# device_calendar reads its classes by reflection; R8 renaming them breaks calendar export in release builds.
-keep class com.builttoroam.devicecalendar.** { *; }
