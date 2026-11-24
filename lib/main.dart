import 'package:cv_flutter_credo/api_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

const _navy = Color(0xFF16364A);
const _teal = Color(0xFF169C8B);
const _ink = Color(0xFF233746);
const _muted = Color(0xFF71818C);
const _canvas = Color(0xFFF3F7F8);
void main() {
  runApp(const CvApp());
}

class CvApp extends StatefulWidget {
  const CvApp({this.apiService, super.key});

  final ApiService? apiService;

  @override
  State<CvApp> createState() => _CvAppState();
}

class _CvAppState extends State<CvApp> {
  bool _isLoggedIn = false;
  late final ApiService _apiService = widget.apiService ?? ApiService();

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
          ? CvHome(
              apiService: _apiService,
              onLogout: () => setState(() => _isLoggedIn = false),
            )
          : LoginPage(
              apiService: _apiService,
              onLogin: () => setState(() => _isLoggedIn = true),
            ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({required this.apiService, required this.onLogin, super.key});

  final ApiService apiService;
  final VoidCallback onLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isRegistering = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      if (_isRegistering) {
        await widget.apiService.register(
          _emailController.text,
          _passwordController.text,
        );
        await widget.apiService.login(
          _emailController.text,
          _passwordController.text,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte créé avec succès.')),
        );
      } else {
        await widget.apiService.login(
          _emailController.text,
          _passwordController.text,
        );
      }
      if (mounted) widget.onLogin();
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de connexion à l’API : $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
                            Text(
                              _isRegistering ? 'Créer un compte' : 'Connexion',
                              style: TextStyle(
                                color: _navy,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 22),
                            TextFormField(
                              key: const Key('login-email'),
                              controller: _emailController,
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Adresse e-mail',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? 'Saisissez votre adresse e-mail.'
                                  : !value.contains('@')
                                  ? 'Saisissez une adresse e-mail valide.'
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
                              onPressed: _isSubmitting ? null : _signIn,
                              style: FilledButton.styleFrom(
                                backgroundColor: _navy,
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                _isSubmitting
                                    ? 'Veuillez patienter...'
                                    : _isRegistering
                                    ? 'Créer mon compte'
                                    : 'Se connecter',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () =>
                              setState(() => _isRegistering = !_isRegistering),
                    child: Text(
                      _isRegistering
                          ? 'J’ai déjà un compte : me connecter'
                          : 'Nouveau ? Créer un compte',
                    ),
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
  const CvHome({required this.apiService, required this.onLogout, super.key});

  final ApiService apiService;
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
        return FamilyPage(apiService: widget.apiService);
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

class FamilyPage extends StatefulWidget {
  const FamilyPage({required this.apiService, super.key});

  final ApiService apiService;

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  late Future<List<FamilyMember>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = widget.apiService.getFamilyMembers();
  }

  void _reload() {
    setState(() => _membersFuture = widget.apiService.getFamilyMembers());
  }

  Future<void> _editMember([FamilyMember? member]) async {
    final payload = await showDialog<FamilyMemberPayload>(
      context: context,
      builder: (context) => FamilyMemberForm(member: member),
    );
    if (payload == null) return;

    try {
      if (member == null) {
        await widget.apiService.createFamilyMember(payload);
      } else {
        await widget.apiService.updateFamilyMember(member.id, payload);
      }
      if (!mounted) return;
      _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(member == null ? 'Membre ajouté.' : 'Membre modifié.'),
        ),
      );
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur API : $error')));
      }
    }
  }

  Future<void> _deleteMember(FamilyMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce membre ?'),
        content: Text('Cette action supprimera ${member.fullName}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await widget.apiService.deleteFamilyMember(member.id);
      if (!mounted) return;
      _reload();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Membre supprimé.')));
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur API : $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageContent(
      children: [
        const PageIntro(
          eyebrow: 'MES PROCHES',
          title: 'Ma famille',
          description:
              'Les membres sont chargés et enregistrés sur le serveur.',
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                key: const Key('family-add'),
                onPressed: () => _editMember(),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Ajouter un membre'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              key: const Key('family-refresh'),
              tooltip: 'Actualiser',
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<FamilyMember>>(
          future: _membersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return InfoCard(
                icon: Icons.cloud_off_outlined,
                title: 'Impossible de charger la famille',
                detail: snapshot.error.toString(),
              );
            }
            final members = snapshot.data ?? const <FamilyMember>[];
            if (members.isEmpty) {
              return const InfoCard(
                icon: Icons.people_outline,
                title: 'Aucun membre enregistré',
                detail: 'Ajoutez un membre pour commencer.',
              );
            }
            return Column(
              children: [
                for (final member in members)
                  FamilyMemberCard(
                    member: member,
                    onEdit: () => _editMember(member),
                    onDelete: () => _deleteMember(member),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class FamilyMemberCard extends StatelessWidget {
  const FamilyMemberCard({
    required this.member,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final FamilyMember member;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final initials =
        '${member.prenom.characters.first}${member.nom.characters.first}';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 27,
              backgroundColor: _teal.withValues(alpha: .1),
              backgroundImage: member.imageUrl == null
                  ? null
                  : NetworkImage(member.imageUrl!),
              child: member.imageUrl == null
                  ? Text(
                      initials,
                      style: const TextStyle(
                        color: _teal,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.fullName,
                    style: const TextStyle(
                      color: _navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${member.parente} · ${member.lieuNaissance} · '
                    '${member.dateNaissance}',
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Modifier',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Supprimer',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}

class FamilyMemberForm extends StatefulWidget {
  const FamilyMemberForm({this.member, super.key});

  final FamilyMember? member;

  @override
  State<FamilyMemberForm> createState() => _FamilyMemberFormState();
}

class _FamilyMemberFormState extends State<FamilyMemberForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nom = TextEditingController(text: widget.member?.nom);
  late final _postnom = TextEditingController(text: widget.member?.postnom);
  late final _prenom = TextEditingController(text: widget.member?.prenom);
  late final _lieu = TextEditingController(text: widget.member?.lieuNaissance);
  late final _date = TextEditingController(text: widget.member?.dateNaissance);
  late final _parente = TextEditingController(text: widget.member?.parente);

  @override
  void dispose() {
    _nom.dispose();
    _postnom.dispose();
    _prenom.dispose();
    _lieu.dispose();
    _date.dispose();
    _parente.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Champ obligatoire.' : null;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      FamilyMemberPayload(
        nom: _nom.text.trim(),
        postnom: _postnom.text.trim(),
        prenom: _prenom.text.trim(),
        lieuNaissance: _lieu.text.trim(),
        dateNaissance: _date.text.trim(),
        parente: _parente.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.member == null ? 'Ajouter un membre' : 'Modifier'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _memberField(_nom, 'Nom'),
                _memberField(_postnom, 'Postnom'),
                _memberField(_prenom, 'Prénom'),
                _memberField(_lieu, 'Lieu de naissance'),
                _memberField(
                  _date,
                  'Date de naissance (AAAA-MM-JJ)',
                  keyboardType: TextInputType.datetime,
                ),
                _memberField(_parente, 'Parenté (ex. : Père, Mère, Frère)'),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.member == null ? 'Ajouter' : 'Enregistrer'),
        ),
      ],
    );
  }

  Widget _memberField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          final requiredError = _required(value);
          if (requiredError != null) return requiredError;
          if (identical(controller, _date) &&
              !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value!.trim())) {
            return 'Utilisez le format AAAA-MM-JJ.';
          }
          return null;
        },
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
