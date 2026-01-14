import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact.dart';

class ContactsService {
  static const String _storageKey = 'quantum_contacts';
  List<Contact> _contacts = [];

  List<Contact> get contacts => List.unmodifiable(_contacts);

  Future<void> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _contacts = jsonList.map((json) => Contact.fromJson(json)).toList();
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _contacts.map((c) => c.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  Future<void> addContact(Contact contact) async {
    // Don't add duplicates
    if (!_contacts.any((c) => c.deviceId == contact.deviceId)) {
      _contacts.add(contact);
      await _saveToStorage();
    }
  }

  Future<void> updateContact(String deviceId, {String? name}) async {
    final index = _contacts.indexWhere((c) => c.deviceId == deviceId);
    if (index != -1) {
      _contacts[index] = _contacts[index].copyWith(name: name);
      await _saveToStorage();
    }
  }

  Future<void> deleteContact(String deviceId) async {
    _contacts.removeWhere((c) => c.deviceId == deviceId);
    await _saveToStorage();
  }

  Contact? getContactByDeviceId(String deviceId) {
    try {
      return _contacts.firstWhere((c) => c.deviceId == deviceId);
    } catch (e) {
      return null;
    }
  }

  bool isContact(String deviceId) {
    return _contacts.any((c) => c.deviceId == deviceId);
  }
}
