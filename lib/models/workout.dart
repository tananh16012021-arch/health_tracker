class WorkoutPlan {
  const WorkoutPlan({
    required this.title,
    required this.level,
    required this.durationMinutes,
    required this.calories,
    required this.focus,
    required this.exercises,
  });

  final String title;
  final String level;
  final int durationMinutes;
  final int calories;
  final String focus;
  final List<String> exercises;
}

const sampleWorkouts = <WorkoutPlan>[
  WorkoutPlan(
    title: 'Full body beginner',
    level: 'Cơ bản',
    durationMinutes: 25,
    calories: 180,
    focus: 'Toàn thân',
    exercises: [
      'Squat 3 x 12',
      'Incline push-up 3 x 10',
      'Glute bridge 3 x 15',
      'Plank 3 x 30 giây',
    ],
  ),
  WorkoutPlan(
    title: 'Fat burn cardio',
    level: 'Trung bình',
    durationMinutes: 18,
    calories: 220,
    focus: 'Đốt mỡ',
    exercises: [
      'Jumping jack 45 giây',
      'Mountain climber 45 giây',
      'High knees 45 giây',
      'Nghỉ 30 giây và lặp 4 vòng',
    ],
  ),
  WorkoutPlan(
    title: 'Mobility & recovery',
    level: 'Nhẹ',
    durationMinutes: 15,
    calories: 70,
    focus: 'Phục hồi',
    exercises: [
      'Cat cow 60 giây',
      'Hip flexor stretch 2 x 45 giây',
      'Shoulder opener 2 x 45 giây',
      'Breathing 3 phút',
    ],
  ),
];
