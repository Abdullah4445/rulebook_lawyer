/// Central vocabulary for the Rulebook lawyer app.
///
/// This file is the single source of truth for legal-domain naming.
/// When in doubt about a term, look here first. UI strings should
/// reference these constants instead of hard-coding.
///
/// Underlying Firestore field names are NOT changed in this layer —
/// for backwards compatibility, code paths still read fields like
/// `serviceId`, `zoneIds`, `driverUsers` etc. The mapping below is
/// purely the user-facing language.
class LegalTerms {
  // ───────────────────────────────────────────────────
  // Roles
  // ───────────────────────────────────────────────────
  static const String lawyer = 'Lawyer';
  static const String customer = 'Customer';
  static const String admin = 'Admin';

  // ───────────────────────────────────────────────────
  // Core entities
  // ───────────────────────────────────────────────────
  static const String case_ = 'Case';
  static const String cases = 'Cases';
  static const String consultation = 'Consultation';
  static const String specialty = 'Specialty';
  static const String specialties = 'Specialties';
  static const String credentials = 'Credentials';
  static const String jurisdiction = 'Jurisdiction';
  static const String jurisdictions = 'Jurisdictions';
  static const String courtAddress = 'Court address';
  static const String consultationVenue = 'Consultation venue';

  // ───────────────────────────────────────────────────
  // Case lifecycle (mirrors Constant.casePlaced/etc.)
  // ───────────────────────────────────────────────────
  static const String caseStatusPlaced = 'Case Placed';
  static const String caseStatusActive = 'Case Active';
  static const String caseStatusInProgress = 'Case In Progress';
  static const String caseStatusCompleted = 'Case Completed';
  static const String caseStatusCanceled = 'Case Canceled';

  // ───────────────────────────────────────────────────
  // Fee model (replaces km-based fares)
  // ───────────────────────────────────────────────────
  static const String consultationFee = 'Consultation fee';
  static const String hourlyRate = 'Hourly rate';
  static const String fixedPackage = 'Fixed package';
  static const String retainer = 'Retainer';

  // ───────────────────────────────────────────────────
  // Lawyer profile fields (legal credentials)
  // ───────────────────────────────────────────────────
  static const String barCouncilId = 'Bar Council ID';
  static const String barRegistrationDate = 'Bar registration date';
  static const String practiceYears = 'Years of practice';
  static const String qualification = 'Qualification';
  static const String lawDegree = 'Law degree';
  static const String officeAddress = 'Office address';
  static const String chamberAddress = 'Chamber address';

  // ───────────────────────────────────────────────────
  // Verbs / actions
  // ───────────────────────────────────────────────────
  static const String acceptCase = 'Accept Case';
  static const String declineCase = 'Decline Case';
  static const String startConsultation = 'Start Consultation';
  static const String completeCase = 'Complete Case';
  static const String cancelCase = 'Cancel Case';
  static const String bookConsultation = 'Book Consultation';

  // ───────────────────────────────────────────────────
  // Brand
  // ───────────────────────────────────────────────────
  static const String brandName = 'Rulebook Lawyer';
  static const String brandTagline =
      'Professional legal services, case management & client support';
}
