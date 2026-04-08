import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_store.dart';
import 'models.dart';

void main() {
  runApp(const GymDexApp());
}

class GymDexApp extends StatefulWidget {
  const GymDexApp({super.key});

  @override
  State<GymDexApp> createState() => _GymDexAppState();
}

class _GymDexAppState extends State<GymDexApp> {
  final AppStore store = AppStore();

  @override
  void initState() {
    super.initState();
    store.load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return MaterialApp(
          title: 'GymDex',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFF6B35),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          home: HomeScreen(store: store),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.store});

  final AppStore store;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(store: widget.store),
      WorkoutPage(store: widget.store),
      NutritionPage(store: widget.store),
      VideosPage(store: widget.store),
      MotivationPage(store: widget.store),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (value) => setState(() => currentIndex = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_filled), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.fitness_center), label: 'Treino'),
          NavigationDestination(icon: Icon(Icons.restaurant), label: 'Calorias'),
          NavigationDestination(icon: Icon(Icons.play_circle_fill), label: 'Videos'),
          NavigationDestination(icon: Icon(Icons.bolt), label: 'Motivacao'),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GymDex')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _metricCard('Saldo Calorico', '${store.netCalories} kcal',
              'Consumidas: ${store.todayCaloriesConsumed} | Gastas: ${store.totalCaloriesBurned}'),
          const SizedBox(height: 12),
          _metricCard('Passos de Hoje', '${store.state.todaySteps}',
              'Meta sugerida: 10.000 passos'),
          const SizedBox(height: 12),
          _metricCard('Streak de Treino', '${store.trainingStreak} dias',
              'Dias treinados: ${store.state.dailyTrainingDates.length}'),
          const SizedBox(height: 20),
          const Text('Fichas cadastradas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...store.state.workoutPlans.map(
            (plan) => Card(
              child: ListTile(
                title: Text(plan.name),
                subtitle: Text('${plan.focus} • ${plan.weekday} • ${plan.exercises.length} exercicios'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(colors: [Color(0xFFFF7B54), Color(0xFFE63946)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key, required this.store});

  final AppStore store;

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final planName = TextEditingController();
  final planFocus = TextEditingController();
  final planWeekday = TextEditingController();
  final exerciseName = TextEditingController();
  final sets = TextEditingController(text: '4');
  final reps = TextEditingController(text: '10-12');
  final restSeconds = TextEditingController(text: '60');
  final calories = TextEditingController(text: '8');
  final videoTitle = TextEditingController();
  final videoUrl = TextEditingController();
  String? selectedPlanId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ficha de Treino')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Criar ficha', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _textField(planName, 'Nome da ficha'),
          _textField(planFocus, 'Foco'),
          _textField(planWeekday, 'Dia da semana'),
          FilledButton(
            onPressed: () async {
              if (planName.text.isEmpty || planFocus.text.isEmpty || planWeekday.text.isEmpty) return;
              await widget.store.addWorkoutPlan(planName.text, planFocus.text, planWeekday.text);
              planName.clear();
              planFocus.clear();
              planWeekday.clear();
              setState(() {});
            },
            child: const Text('Salvar ficha'),
          ),
          const SizedBox(height: 24),
          const Text('Adicionar exercicio', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedPlanId,
            items: widget.store.state.workoutPlans
                .map((plan) => DropdownMenuItem(value: plan.id, child: Text(plan.name)))
                .toList(),
            onChanged: (value) => setState(() => selectedPlanId = value),
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Ficha'),
          ),
          const SizedBox(height: 8),
          _textField(exerciseName, 'Exercicio'),
          _textField(sets, 'Series'),
          _textField(reps, 'Repeticoes'),
          _textField(restSeconds, 'Descanso em segundos'),
          _textField(calories, 'Calorias por serie'),
          _textField(videoTitle, 'Titulo do video'),
          _textField(videoUrl, 'URL do video'),
          FilledButton(
            onPressed: () async {
              if (selectedPlanId == null || exerciseName.text.isEmpty) return;
              final exercise = WorkoutExercise(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                name: exerciseName.text,
                sets: int.tryParse(sets.text) ?? 4,
                reps: reps.text,
                restSeconds: int.tryParse(restSeconds.text) ?? 60,
                caloriesPerSet: int.tryParse(calories.text) ?? 8,
                videoTitle: videoTitle.text.isEmpty ? 'Como fazer ${exerciseName.text}' : videoTitle.text,
                videoUrl: videoUrl.text.isEmpty
                    ? 'https://www.youtube.com/results?search_query=${exerciseName.text.replaceAll(' ', '+')}+execucao+correta'
                    : videoUrl.text,
              );
              await widget.store.addExercise(selectedPlanId!, exercise);
              exerciseName.clear();
              sets.text = '4';
              reps.text = '10-12';
              restSeconds.text = '60';
              calories.text = '8';
              videoTitle.clear();
              videoUrl.clear();
              setState(() {});
            },
            child: const Text('Adicionar exercicio'),
          ),
          const SizedBox(height: 24),
          ...widget.store.state.workoutPlans.map(
            (plan) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('${plan.focus} • ${plan.weekday}'),
                    const SizedBox(height: 8),
                    ...plan.exercises.map((exercise) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text('${exercise.name} • ${exercise.sets}x ${exercise.reps} • descanso ${exercise.restSeconds}s'),
                        )),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () async => widget.store.completeWorkout(plan.id),
                      child: Text(plan.completedDates.contains(_todayKey())
                          ? 'Treino ja registrado hoje'
                          : 'Registrar treino do dia'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key, required this.store});

  final AppStore store;

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  final foodName = TextEditingController();
  final calories = TextEditingController();
  final protein = TextEditingController();
  final carbs = TextEditingController();
  final fats = TextEditingController();
  final analysisText = TextEditingController();
  final steps = TextEditingController();
  FoodAnalysis? latestAnalysis;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calorias')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Meta diaria: ${widget.store.state.calorieGoal} kcal'),
                  Text('Consumidas hoje: ${widget.store.todayCaloriesConsumed} kcal'),
                  Text('Gastas hoje: ${widget.store.totalCaloriesBurned} kcal'),
                  Text('Saldo: ${widget.store.netCalories} kcal'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Registrar refeicao', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _textField(foodName, 'Nome da refeicao'),
          _textField(calories, 'Calorias'),
          _textField(protein, 'Proteina'),
          _textField(carbs, 'Carboidratos'),
          _textField(fats, 'Gorduras'),
          FilledButton(
            onPressed: () async {
              if (foodName.text.isEmpty) return;
              await widget.store.addFood(
                foodName.text,
                int.tryParse(calories.text) ?? 0,
                int.tryParse(protein.text) ?? 0,
                int.tryParse(carbs.text) ?? 0,
                int.tryParse(fats.text) ?? 0,
              );
              foodName.clear();
              calories.clear();
              protein.clear();
              carbs.clear();
              fats.clear();
            },
            child: const Text('Adicionar refeicao'),
          ),
          const SizedBox(height: 24),
          const Text('Analisador de comida', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _textField(analysisText, 'Ex: 2 ovos, arroz, frango e banana', maxLines: 3),
          FilledButton(
            onPressed: () async {
              if (analysisText.text.isEmpty) return;
              final analysis = await widget.store.analyzeFood(analysisText.text);
              setState(() => latestAnalysis = analysis);
            },
            child: const Text('Analisar'),
          ),
          if (latestAnalysis != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Resultado estimado: ${latestAnalysis!.totalCalories} kcal',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...latestAnalysis!.detectedItems.map((item) => Text('${item.name}: ${item.calories} kcal')),
                    const SizedBox(height: 8),
                    Text(latestAnalysis!.notes),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Text('Contador de passos', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Passos hoje: ${widget.store.state.todaySteps}'),
          const SizedBox(height: 8),
          _textField(steps, 'Atualizar passos manualmente'),
          FilledButton(
            onPressed: () async => widget.store.updateSteps(int.tryParse(steps.text) ?? 0),
            child: const Text('Salvar passos'),
          ),
        ],
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class VideosPage extends StatelessWidget {
  const VideosPage({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca de Videos')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: store.state.videos.length,
        itemBuilder: (context, index) {
          final video = store.state.videos[index];
          return Card(
            child: ListTile(
              title: Text(video.exerciseName),
              subtitle: Text('${video.title}\n${video.category}'),
              isThreeLine: true,
              trailing: IconButton(
                onPressed: () => _openUrl(video.url),
                icon: const Icon(Icons.open_in_new),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class MotivationPage extends StatefulWidget {
  const MotivationPage({super.key, required this.store});

  final AppStore store;

  @override
  State<MotivationPage> createState() => _MotivationPageState();
}

class _MotivationPageState extends State<MotivationPage> {
  final nickname = TextEditingController();
  String selectedStarter = 'Charmander';
  String captureMessage = '';

  @override
  Widget build(BuildContext context) {
    final starter = widget.store.state.starter;
    return Scaffold(
      appBar: AppBar(title: const Text('Motivacao')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Seu motivador', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(starter.nickname, style: const TextStyle(fontSize: 16)),
                  Text(starter.species, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  Text('Estagio ${starter.stage} • XP ${starter.xp} • Vitorias ${starter.battlesWon}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Escolher inicial', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedStarter,
            items: const ['Bulbasaur', 'Charmander', 'Squirtle']
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) => setState(() => selectedStarter = value ?? 'Charmander'),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nickname,
            decoration: const InputDecoration(
              labelText: 'Apelido',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () async => widget.store.chooseStarter(selectedStarter, nickname.text),
            child: const Text('Definir inicial'),
          ),
          const SizedBox(height: 24),
          const Text('Captura de novos pokemons', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () async {
              final message = await widget.store.captureCreature();
              setState(() => captureMessage = message);
            },
            child: const Text('Tentar captura'),
          ),
          if (captureMessage.isNotEmpty) Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(captureMessage),
          ),
          const SizedBox(height: 12),
          ...widget.store.state.capturedSpecies.map((species) => Card(
                child: ListTile(title: Text(species)),
              )),
          const SizedBox(height: 24),
          const Text('Historico de batalhas', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...widget.store.state.battleLogs.map((battle) => Card(
                child: ListTile(
                  title: Text(battle.planName),
                  subtitle: Text(battle.summary),
                ),
              )),
        ],
      ),
    );
  }
}

String _todayKey() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '${now.year}-$month-$day';
}
