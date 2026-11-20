import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

const _navy = Color(0xFF16364A);
const _teal = Color(0xFF169C8B);
const _ink = Color(0xFF233746);
const _muted = Color(0xFF71818C);
const _canvas = Color(0xFFF3F7F8);
const _demoUsername = 'credo';
const _demoPassword = '123456';

void main() {
  runApp(const CvApp());
}

class CvApp extends StatefulWidget {
  const CvApp({super.key});

  @override
  State<CvApp> createState() => _CvAppState();
}

class _CvAppState extends State<CvApp> {
  bool _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CV de Credo PUTCHU NGONGO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _teal,
          primary: _navy,
          secondary: _teal,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: _canvas,
        appBarTheme: const AppBarTheme(
          backgroundColor: _canvas,
          foregroundColor: _navy,
          centerTitle: false,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _canvas,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _navy.withValues(alpha: .08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _teal, width: 1.5),
          ),
        ),
      ),
      home: _isLoggedIn
          ? CvHome(onLogout: () => setState(() => _isLoggedIn = false))
          : LoginPage(onLogin: () => setState(() => _isLoggedIn = true)),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({required this.onLogin, super.key});

  final VoidCallback onLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (!_formKey.currentState!.validate()) return;

    if (_usernameController.text.trim() == _demoUsername &&
        _passwordController.text == _demoPassword) {
      widget.onLogin();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Identifiant ou mot de passe incorrect.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: _teal.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: const Icon(
                        Icons.flight_takeoff_rounded,
                        color: _teal,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Bonjour, bienvenue',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(color: _navy, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    'Connectez-vous pour découvrir mon parcours.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted, height: 1.5),
                  ),
                  const SizedBox(height: 34),
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Connexion',
                              style: TextStyle(
                                color: _navy,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 22),
                            TextFormField(
                              key: const Key('login-username'),
                              controller: _usernameController,
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              decoration: const InputDecoration(
                                labelText: 'Identifiant',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? 'Saisissez votre identifiant.'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              key: const Key('login-password'),
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              onFieldSubmitted: (_) => _signIn(),
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: _obscurePassword
                                      ? 'Afficher le mot de passe'
                                      : 'Masquer le mot de passe',
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Saisissez votre mot de passe.'
                                  : null,
                            ),
                            const SizedBox(height: 22),
                            FilledButton(
                              key: const Key('login-submit'),
                              onPressed: _signIn,
                              style: FilledButton.styleFrom(
                                backgroundColor: _navy,
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Se connecter'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Accès démo : $_demoUsername  ·  $_demoPassword',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CvHome extends StatefulWidget {
  const CvHome({required this.onLogout, super.key});

  final VoidCallback onLogout;

  @override
  State<CvHome> createState() => _CvHomeState();
}

class _CvHomeState extends State<CvHome> {
  int _selectedIndex = 0;

  static const _titles = ['Mon CV', 'Ma famille', 'Contact'];

  Widget _pageForIndex(int index) {
    switch (index) {
      case 1:
        return const FamilyPage();
      case 2:
        return const ContactPage();
      default:
        return const ResumePage();
    }
  }

  void _selectPage(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Se déconnecter',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(22, 24, 22, 22),
                child: Row(
                  children: [
                    ProfileAvatar(size: 56),
                    SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Credo PUTCHU NGONGO',
                          style: TextStyle(
                            color: _navy,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text('Informaticien · Aviateur'),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              for (var index = 0; index < _titles.length; index++)
                ListTile(
                  leading: Icon(
                    [
                      Icons.badge_outlined,
                      Icons.family_restroom_rounded,
                      Icons.alternate_email_rounded,
                    ][index],
                  ),
                  title: Text(_titles[index]),
                  selected: _selectedIndex == index,
                  onTap: () => _selectPage(index),
                ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('Se déconnecter'),
                onTap: widget.onLogout,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      body: _pageForIndex(_selectedIndex),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            key: Key('nav-cv'),
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge_rounded),
            label: 'Mon CV',
          ),
          NavigationDestination(
            key: Key('nav-family'),
            icon: Icon(Icons.family_restroom_outlined),
            selectedIcon: Icon(Icons.family_restroom_rounded),
            label: 'Famille',
          ),
          NavigationDestination(
            key: Key('nav-contact'),
            icon: Icon(Icons.alternate_email_outlined),
            selectedIcon: Icon(Icons.alternate_email_rounded),
            label: 'Contact',
          ),
        ],
      ),
    );
  }
}

class PageContent extends StatelessWidget {
  const PageContent({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

class ResumePage extends StatelessWidget {
  const ResumePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContent(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [_navy, Color(0xFF23566A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileAvatar(size: 76, light: true),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CURRICULUM VITAE',
                          style: TextStyle(
                            color: Color(0xFF9DE1D6),
                            letterSpacing: 1.6,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Credo PUTCHU NGONGO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Informaticien · Aviateur',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Curieux des technologies et du monde aérien. '
                'Formation et présentation personnelle à compléter.',
                style: TextStyle(color: Colors.white, height: 1.55),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const SectionHeading(title: 'Formation', icon: Icons.school_outlined),
        const InfoCard(
          icon: Icons.menu_book_rounded,
          title: 'Formation à renseigner',
          detail: 'Ajoutez votre établissement, votre diplôme et les dates.',
        ),
        const SizedBox(height: 18),
        const SectionHeading(
          title: 'Expériences',
          icon: Icons.work_outline_rounded,
        ),
        const InfoCard(
          icon: Icons.computer_rounded,
          title: 'Informaticien',
          detail: 'Poste, missions et dates à compléter.',
        ),
        const InfoCard(
          icon: Icons.flight_rounded,
          title: 'Aviateur',
          detail: 'Expérience, qualifications et dates à compléter.',
        ),
        const SizedBox(height: 18),
        const SectionHeading(
          title: 'Compétences techniques',
          icon: Icons.auto_awesome_outlined,
        ),
        const InfoCard(
          icon: Icons.tips_and_updates_outlined,
          title: 'À personnaliser',
          detail:
              'Ajoutez vos outils, technologies, licences et certifications.',
        ),
        const SizedBox(height: 18),
        const SectionHeading(title: 'Langues', icon: Icons.translate_rounded),
        const InfoCard(
          icon: Icons.language_rounded,
          title: 'Langues parlées',
          detail:
              'Français · Anglais · Swahili · Lingala · Niveaux à préciser.',
        ),
        const SizedBox(height: 18),
        const SectionHeading(
          title: 'Centres d’intérêt',
          icon: Icons.interests_outlined,
        ),
        const InfoCard(
          icon: Icons.favorite_border_rounded,
          title: 'À renseigner',
          detail: 'Ajoutez vos activités et centres d’intérêt.',
        ),
      ],
    );
  }
}

class FamilyPage extends StatelessWidget {
  const FamilyPage({super.key});

  static const _members = [
    ('Mulenda RAPHAEL', 'Père'),
    ('Ashimba COLETTE', 'Mère'),
    ('DON-LOUIS', 'Frère / sœur'),
    ('GRACE', 'Frère / sœur'),
    ('MAGNIFIQUE', 'Frère / sœur'),
  ];

  @override
  Widget build(BuildContext context) {
    return PageContent(
      children: [
        const PageIntro(
          eyebrow: 'MES PROCHES',
          title: 'Ma famille',
          description:
              'Les personnes qui comptent le plus. Les photos pourront être '
              'ajoutées à chaque profil.',
        ),
        const SizedBox(height: 18),
        for (final (name, relation) in _members)
          FamilyMemberCard(name: name, relation: relation),
      ],
    );
  }
}

class FamilyMemberCard extends StatelessWidget {
  const FamilyMemberCard({
    required this.name,
    required this.relation,
    super.key,
  });

  final String name;
  final String relation;

  String get _initials {
    final parts = name.split(RegExp(r'\s+'));
    return parts.length == 1
        ? parts.first.substring(0, 1)
        : '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 29,
              backgroundColor: _teal.withValues(alpha: .1),
              child: Text(
                _initials,
                style: const TextStyle(
                  color: _teal,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: _navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(relation, style: const TextStyle(color: _muted)),
                ],
              ),
            ),
            const Icon(Icons.add_a_photo_outlined, color: _muted, size: 19),
          ],
        ),
      ),
    );
  }
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContent(
      children: [
        const PageIntro(
          eyebrow: 'RESTONS EN CONTACT',
          title: 'Me contacter',
          description:
              'Une question ou une opportunité ? Vous pouvez me joindre '
              'directement.',
        ),
        const SizedBox(height: 20),
        ContactCard(
          icon: Icons.call_outlined,
          title: 'Téléphone',
          value: '+243 973 013 215',
          onTap: () =>
              _openContact(context, Uri(scheme: 'tel', path: '+243973013215')),
        ),
        ContactCard(
          icon: Icons.mail_outline_rounded,
          title: 'E-mail',
          value: 'credomulenda002@gmail.com',
          onTap: () => _openContact(
            context,
            Uri(scheme: 'mailto', path: 'credomulenda002@gmail.com'),
          ),
        ),
        const ContactCard(
          icon: Icons.location_on_outlined,
          title: 'Adresse',
          value: 'À renseigner',
        ),
        ContactCard(
          icon: Icons.camera_alt_outlined,
          title: 'Instagram',
          value: 'credo___mld',
          onTap: () => _openContact(
            context,
            Uri.https('www.instagram.com', '/credo___mld/'),
          ),
        ),
        const SizedBox(height: 12),
        const InfoCard(
          icon: Icons.link_rounded,
          title: 'LinkedIn · GitHub',
          detail: 'Ajoutez vos liens de profil.',
        ),
      ],
    );
  }

  Future<void> _openContact(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ouvrir ce lien.')),
      );
    }
  }
}

class ContactCard extends StatelessWidget {
  const ContactCard({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _teal.withValues(alpha: .1),
          child: Icon(icon, color: _teal),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: _navy,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            value,
            style: const TextStyle(color: _ink, fontWeight: FontWeight.w600),
          ),
        ),
        trailing: onTap == null
            ? null
            : const Icon(Icons.open_in_new_rounded, size: 18, color: _muted),
      ),
    );
  }
}

class PageIntro extends StatelessWidget {
  const PageIntro({
    required this.eyebrow,
    required this.title,
    required this.description,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              color: _teal,
              letterSpacing: 1.5,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(color: _navy, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 7),
          Text(description, style: const TextStyle(color: _muted, height: 1.5)),
        ],
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({required this.title, required this.icon, super.key});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 9),
      child: Row(
        children: [
          Icon(icon, color: _teal, size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: _navy,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.icon,
    required this.title,
    required this.detail,
    super.key,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        leading: Icon(icon, color: _teal, size: 22),
        title: Text(
          title,
          style: const TextStyle(color: _navy, fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            detail,
            style: const TextStyle(color: _muted, height: 1.4),
          ),
        ),
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({required this.size, this.light = false, super.key});

  final double size;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: light
          ? Colors.white.withValues(alpha: .13)
          : _teal.withValues(alpha: .1),
      backgroundImage: const AssetImage('assets/credo-profile.jpg'),
      foregroundImage: const AssetImage('assets/credo-profile.jpg'),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: light ? _navy.withValues(alpha: .12) : Colors.transparent,
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: const Icon(
            Icons.add_a_photo_outlined,
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
