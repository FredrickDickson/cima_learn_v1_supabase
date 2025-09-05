import '../models/cima_course.dart';

class CIMACourseService {
  static final CIMACourseService _instance = CIMACourseService._internal();
  factory CIMACourseService() => _instance;
  CIMACourseService._internal();

  // CIMA courses based on the brochure
  List<CIMACourse> getAllCourses() {
    return [
      // FOUNDATIONAL MASTERCLASS
      CIMACourse(
        id: 'cima-001',
        title: 'Law, Practice & Procedure in Domestic and International Arbitration',
        description: 'Our flagship foundational course delivering in-depth training on legal principles, processes, and procedures that underpin domestic and international arbitration. Designed for aspiring and seasoned professionals alike.',
        instructor: 'CIMA Faculty Experts',
        price: 750.00,
        rating: 4.8,
        reviewCount: 150,
        studentCount: 500,
        image: 'assets/images/arbitration-london.jpg',
        duration: '3 days',
        cimaLevel: CIMALevel.associate,
        courseCategory: CourseCategory.arbitration,
        sessionCount: 8,
        deliveryMode: 'hybrid',
        learningOutcomes: [
          'Understand fundamental principles of domestic and international arbitration',
          'Navigate procedural frameworks effectively',
          'Apply key legislation including UNCITRAL Model Law',
          'Analyse complex disputes using critical thinking',
          'Draft and review arbitration agreements'
        ],
        certificationOffered: 'Certificate of Completion + Associate Membership (ACIMArb)',
        isFoundational: true,
        practicalHours: 12.0,
        theoryHours: 12.0,
      ),

      // INTRODUCTION TO ADR
      CIMACourse(
        id: 'cima-002',
        title: 'Introduction to Alternative Dispute Resolution (ADR)',
        description: 'Comprehensive introduction to ADR covering arbitration, mediation, and adjudication. Perfect for beginners seeking to understand the fundamentals of dispute resolution.',
        instructor: 'Leading ADR Practitioners',
        price: 450.00,
        rating: 4.7,
        reviewCount: 120,
        studentCount: 350,
        image: 'assets/images/mediation-fundamentals.jpg',
        duration: '2 days',
        cimaLevel: CIMALevel.associate,
        courseCategory: CourseCategory.adr,
        sessionCount: 8,
        deliveryMode: 'hybrid',
        learningOutcomes: [
          'Understand fundamental principles of ADR',
          'Identify different forms of ADR and their applications',
          'Learn legal framework governing ADR',
          'Develop negotiation and conflict resolution skills',
          'Draft enforceable ADR clauses'
        ],
        certificationOffered: 'Certificate of Completion + Associate Membership (ACIMArb)',
        isFoundational: true,
        practicalHours: 8.0,
        theoryHours: 8.0,
      ),

      // INTERNATIONAL COMMERCIAL ARBITRATION
      CIMACourse(
        id: 'cima-003',
        title: 'International Commercial Arbitration Practice',
        description: 'Advanced course focusing on international commercial arbitration with emphasis on ICC, LCIA, and UNCITRAL procedures. Includes case studies and practical simulations.',
        instructor: 'International Arbitration Panel',
        price: 1200.00,
        rating: 4.9,
        reviewCount: 200,
        studentCount: 800,
        image: 'assets/images/commercial-law.jpg',
        duration: '5 days'
        cimaLevel: CIMALevel.member,
        courseCategory: CourseCategory.commercial,
        prerequisites: ['Basic understanding of arbitration principles'],
        sessionCount: 15,
        deliveryMode: 'hybrid',
        learningOutcomes: [
          'Master international arbitration procedures',
          'Handle complex commercial disputes',
          'Understand institutional rules (ICC, LCIA, ICSID)',
          'Conduct arbitration hearings effectively',
          'Manage multi-jurisdictional disputes'
        ],
        certificationOffered: 'CIMA Professional Certificate + Member Eligibility (MCIMArb)',
        practicalHours: 20.0,
        theoryHours: 20.0,
      ),

      // CONSTRUCTION DISPUTE RESOLUTION
      CIMACourse(
        id: 'cima-004',
        title: 'Construction Dispute Resolution & Adjudication',
        description: 'Specialized course for construction industry professionals covering adjudication, arbitration, and mediation in construction disputes.',
        instructor: 'Construction Law Experts',
        price: 850.00,
        rating: 4.6,
        reviewCount: 85,
        studentCount: 300,
        image: 'assets/images/construction-dispute.jpg',
        duration: '4 days'
        cimaLevel: CIMALevel.member,
        courseCategory: CourseCategory.construction,
        sessionCount: 12,
        deliveryMode: 'hybrid',
        learningOutcomes: [
          'Understand construction contract disputes',
          'Apply adjudication procedures effectively',
          'Handle delay and disruption claims',
          'Manage technical evidence in disputes',
          'Draft construction dispute clauses'
        ],
        certificationOffered: 'CIMA Construction Dispute Resolution Certificate',
        practicalHours: 16.0,
        theoryHours: 16.0,
      ),

      // MEDIATION MASTERCLASS
      CIMACourse(
        id: 'cima-005',
        title: 'Advanced Mediation Practice & Skills',
        description: 'Comprehensive mediation training covering negotiation psychology, cultural considerations, and advanced mediation techniques.',
        instructor: 'Certified Mediation Professionals',
        price: 650.00,
        rating: 4.8,
        reviewCount: 95,
        studentCount: 250,
        image: 'assets/images/advanced-mediation.jpg',
        duration: '3 days'
        cimaLevel: CIMALevel.member,
        courseCategory: CourseCategory.mediation,
        sessionCount: 10,
        deliveryMode: 'hybrid',
        learningOutcomes: [
          'Master advanced mediation techniques',
          'Understand cross-cultural mediation',
          'Handle high-conflict situations',
          'Design settlement agreements',
          'Manage multi-party mediations'
        ],
        certificationOffered: 'CIMA Certified Mediator Certificate',
        practicalHours: 15.0,
        theoryHours: 9.0,
      ),

      // INVESTMENT ARBITRATION
      CIMACourse(
        id: 'cima-006',
        title: 'Investment Treaty Arbitration (ICSID & UNCITRAL)',
        description: 'Specialized course on investment arbitration covering ICSID procedures, bilateral investment treaties, and state-investor disputes.',
        instructor: 'Investment Law Specialists',
        price: 1500.00,
        rating: 4.9,
        reviewCount: 75,
        studentCount: 150,
        image: 'assets/images/investment-arbitration.jpg',
        duration: '6 days'
        cimaLevel: CIMALevel.fellow,
        courseCategory: CourseCategory.investment,
        prerequisites: ['International arbitration experience', 'Public international law background'],
        sessionCount: 18,
        deliveryMode: 'hybrid',
        learningOutcomes: [
          'Navigate ICSID arbitration procedures',
          'Understand bilateral investment treaties',
          'Handle sovereign immunity issues',
          'Manage state-investor disputes',
          'Apply international investment law'
        ],
        certificationOffered: 'CIMA Investment Arbitration Specialist Certificate',
        practicalHours: 24.0,
        theoryHours: 24.0,
      ),

      // MARITIME ARBITRATION
      CIMACourse(
        id: 'cima-007',
        title: 'Maritime & Shipping Arbitration',
        description: 'Specialized training in maritime disputes covering charter party disputes, collision claims, and salvage arbitrations.',
        instructor: 'Maritime Law Experts',
        price: 950.00,
        rating: 4.7,
        reviewCount: 60,
        studentCount: 180,
        image: 'assets/images/arbitration-london.jpg',
        duration: '4 days'
        cimaLevel: CIMALevel.member,
        courseCategory: CourseCategory.maritime,
        sessionCount: 12,
        deliveryMode: 'virtual',
        learningOutcomes: [
          'Understand maritime commercial law',
          'Handle shipping disputes effectively',
          'Apply LMAA arbitration procedures',
          'Manage technical maritime evidence',
          'Resolve charter party disputes'
        ],
        certificationOffered: 'CIMA Maritime Arbitration Certificate',
        practicalHours: 16.0,
        theoryHours: 16.0,
      ),

      // SPORTS ARBITRATION
      CIMACourse(
        id: 'cima-008',
        title: 'Sports Arbitration & CAS Procedures',
        description: 'Comprehensive course on sports disputes covering CAS procedures, doping cases, and commercial sports disputes.',
        instructor: 'Sports Law Panel',
        price: 750.00,
        rating: 4.6,
        reviewCount: 45,
        studentCount: 120,
        image: 'assets/images/ethics-arbitration.jpg',
        duration: '3 days'
        cimaLevel: CIMALevel.member,
        courseCategory: CourseCategory.sports,
        sessionCount: 10,
        deliveryMode: 'virtual',
        learningOutcomes: [
          'Navigate CAS arbitration procedures',
          'Handle doping and disciplinary cases',
          'Understand sports contract disputes',
          'Apply lex sportiva principles',
          'Manage urgent sports arbitrations'
        ],
        certificationOffered: 'CIMA Sports Arbitration Certificate',
        practicalHours: 12.0,
        theoryHours: 12.0,
      ),

      // ONLINE DISPUTE RESOLUTION
      CIMACourse(
        id: 'cima-009',
        title: 'Online Dispute Resolution (ODR) & Digital Arbitration',
        description: 'Cutting-edge course on digital dispute resolution, cybersecurity in arbitration, and AI applications in dispute resolution.',
        instructor: 'Technology & Law Experts',
        price: 550.00,
        rating: 4.5,
        reviewCount: 80,
        studentCount: 220,
        image: 'assets/images/compliance-risk.jpg',
        duration: '2 days'
        cimaLevel: CIMALevel.associate,
        courseCategory: CourseCategory.technology,
        sessionCount: 8,
        deliveryMode: 'virtual',
        learningOutcomes: [
          'Understand ODR platforms and procedures',
          'Apply cybersecurity best practices',
          'Utilize AI tools in dispute resolution',
          'Handle virtual arbitration hearings',
          'Ensure confidentiality in digital processes'
        ],
        certificationOffered: 'CIMA Digital Dispute Resolution Certificate',
        isFoundational: true,
        practicalHours: 8.0,
        theoryHours: 8.0,
      ),

      // FELLOWSHIP PROGRAM
      CIMACourse(
        id: 'cima-010',
        title: 'CIMA Fellowship Program (FCIMArb Pathway)',
        description: 'Intensive program for experienced practitioners seeking Fellowship status. Includes thesis submission, peer review, and advanced practice requirements.',
        instructor: 'CIMA Fellowship Board',
        price: 2500.00,
        rating: 5.0,
        reviewCount: 25,
        studentCount: 50,
        image: 'assets/images/diac-rules.jpg',
        duration: '12 months'
        cimaLevel: CIMALevel.fellow,
        courseCategory: CourseCategory.arbitration,
        prerequisites: ['MCIMArb status', 'Minimum 5 years arbitration experience', 'Portfolio of cases'],
        sessionCount: 24,
        deliveryMode: 'hybrid',
        learningOutcomes: [
          'Demonstrate mastery of arbitration practice',
          'Contribute original research to the field',
          'Mentor junior practitioners',
          'Lead complex international arbitrations',
          'Shape future of dispute resolution'
        ],
        certificationOffered: 'Fellowship of CIMA (FCIMArb)',
        practicalHours: 100.0,
        theoryHours: 50.0,
      ),
    ];
  }

  List<CIMACourse> searchCourses({
    String? query,
    CIMALevel? level,
    CourseCategory? category,
    String? deliveryMode,
    bool? isFoundational,
    double? maxPrice,
  }) {
    var courses = getAllCourses();

    if (query != null && query.isNotEmpty) {
      final lowercaseQuery = query.toLowerCase();
      courses = courses.where((course) =>
        course.title.toLowerCase().contains(lowercaseQuery) ||
        course.description.toLowerCase().contains(lowercaseQuery) ||
        course.categoryDisplayName.toLowerCase().contains(lowercaseQuery) ||
        course.learningOutcomes.any((outcome) => outcome.toLowerCase().contains(lowercaseQuery))
      ).toList();
    }

    if (level != null) {
      courses = courses.where((course) => course.level == level).toList();
    }

    if (category != null) {
      courses = courses.where((course) => course.category == category).toList();
    }

    if (deliveryMode != null) {
      courses = courses.where((course) => course.deliveryMode.toLowerCase() == deliveryMode.toLowerCase()).toList();
    }

    if (isFoundational != null) {
      courses = courses.where((course) => course.isFoundational == isFoundational).toList();
    }

    if (maxPrice != null) {
      courses = courses.where((course) => course.price <= maxPrice).toList();
    }

    return courses;
  }

  List<CIMACourse> getCoursesByLevel(CIMALevel level) {
    return getAllCourses().where((course) => course.level == level).toList();
  }

  List<CIMACourse> getCoursesByCategory(CourseCategory category) {
    return getAllCourses().where((course) => course.category == category).toList();
  }

  List<CIMACourse> getFoundationalCourses() {
    return getAllCourses().where((course) => course.isFoundational).toList();
  }

  List<String> getAllCategories() {
    return CourseCategory.values.map((cat) => cat.toString().split('.').last).toList();
  }

  List<String> getAllLevels() {
    return CIMALevel.values.map((level) => level.toString().split('.').last).toList();
  }
}