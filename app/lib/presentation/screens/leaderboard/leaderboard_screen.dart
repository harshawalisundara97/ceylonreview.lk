import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/leaderboard_provider.dart';
import '../../../core/l10n_ext.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/leaderboard_entry.dart';
import '../../widgets/user_avatar.dart';

/// Leaderboard: an animated podium for the top 3, the signed-in user's own
/// rank (if outside the top 3), and an animated list for everyone else.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider);
    final myRank = ref.watch(myRankProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.leaderboard)),
      body: leaderboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            Center(child: Text(context.l10n.couldNotLoadLeaderboard)),
        data: (entries) {
          if (entries.isEmpty) {
            return const _EmptyLeaderboard();
          }
          final top = entries.take(3).toList();
          final rest = entries.skip(3).toList();
          final myEntry = myRank.valueOrNull;
          final showMyRankCard = myEntry != null && myEntry.rank > 3;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            children: [
              _Podium(top: top),
              const SizedBox(height: AppSpacing.lg),
              if (showMyRankCard) ...[
                _YourRankCard(
                  entry: myEntry,
                  pointsToNext: _pointsToNextRank(entries, myEntry),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              for (var i = 0; i < rest.length; i++)
                _LeaderboardRow(
                  entry: rest[i],
                  isMe: myEntry?.userId == rest[i].userId,
                  staggerIndex: i,
                ),
            ],
          );
        },
      ),
    );
  }

  /// Points needed to overtake the next-higher entry, or null if [mine] is
  /// already rank 1 or not found in [entries].
  int? _pointsToNextRank(List<LeaderboardEntry> entries, LeaderboardEntry mine) {
    final index = entries.indexWhere((e) => e.userId == mine.userId);
    if (index <= 0) return null;
    return entries[index - 1].points - mine.points + 1;
  }
}

class _EmptyLeaderboard extends StatelessWidget {
  const _EmptyLeaderboard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          context.l10n.leaderboardEmptyState,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.top});

  final List<LeaderboardEntry> top;

  LeaderboardEntry? _at(int rank) {
    for (final e in top) {
      if (e.rank == rank) return e;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final first = _at(1);
    final second = _at(2);
    final third = _at(3);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (second != null)
          Expanded(child: _PodiumSlot(entry: second, delayMs: 150)),
        if (first != null)
          Expanded(
              flex: 1, child: _PodiumSlot(entry: first, delayMs: 0, isFirst: true)),
        if (third != null)
          Expanded(child: _PodiumSlot(entry: third, delayMs: 300)),
      ],
    );
  }
}

class _PodiumSlot extends StatefulWidget {
  const _PodiumSlot({
    required this.entry,
    required this.delayMs,
    this.isFirst = false,
  });

  final LeaderboardEntry entry;
  final int delayMs;
  final bool isFirst;

  @override
  State<_PodiumSlot> createState() => _PodiumSlotState();
}

class _PodiumSlotState extends State<_PodiumSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _riseController;
  late final Animation<double> _rise;

  @override
  void initState() {
    super.initState();
    _riseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _rise = CurvedAnimation(parent: _riseController, curve: Curves.easeOut);
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _riseController.forward();
    });
  }

  @override
  void dispose() {
    _riseController.dispose();
    super.dispose();
  }

  Color _barColor(BuildContext context) {
    final tokens = Theme.of(context).extension<CeylonTokens>()!;
    return switch (widget.entry.rank) {
      1 => tokens.star,
      2 => const Color(0xFF9AA3AB),
      _ => const Color(0xFFCD8A4D),
    };
  }

  double _barHeight() => switch (widget.entry.rank) {
        1 => 92,
        2 => 66,
        _ => 46,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarRadius = widget.isFirst ? 42.0 : 32.0;

    return AnimatedBuilder(
      animation: _rise,
      builder: (context, child) => Opacity(
        opacity: _rise.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _rise.value) * 24),
          child: child,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isFirst)
            const _BobbingCrown(),
          UserAvatar(name: widget.entry.name, radius: avatarRadius),
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.entry.name,
            style: theme.textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          _CountUpPoints(target: widget.entry.points),
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            height: _barHeight(),
            width: 72,
            decoration: BoxDecoration(
              color: _barColor(context),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.md)),
            ),
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              '${widget.entry.rank}',
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: theme.colorScheme.surface),
            ),
          ),
        ],
      ),
    );
  }
}

class _BobbingCrown extends StatefulWidget {
  const _BobbingCrown();

  @override
  State<_BobbingCrown> createState() => _BobbingCrownState();
}

class _BobbingCrownState extends State<_BobbingCrown>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -4 * _controller.value),
        child: child,
      ),
      child: const Text('👑', style: TextStyle(fontSize: 26)),
    );
  }
}

class _CountUpPoints extends StatelessWidget {
  const _CountUpPoints({required this.target});

  final int target;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<CeylonTokens>()!;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: target.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Text(
        context.l10n.nPts('${value.round()}'),
        style: theme.textTheme.labelMedium?.copyWith(color: tokens.star),
      ),
    );
  }
}

class _YourRankCard extends StatelessWidget {
  const _YourRankCard({required this.entry, required this.pointsToNext});

  final LeaderboardEntry entry;
  final int? pointsToNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<CeylonTokens>()!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text('#${entry.rank}',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.primary)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.you, style: theme.textTheme.titleSmall),
                if (pointsToNext != null)
                  Text(context.l10n.ptsToReach('$pointsToNext', '${entry.rank - 1}'),
                      style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Text(context.l10n.nPts('${entry.points}'),
              style: theme.textTheme.titleSmall?.copyWith(color: tokens.star)),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatefulWidget {
  const _LeaderboardRow({
    required this.entry,
    required this.isMe,
    required this.staggerIndex,
  });

  final LeaderboardEntry entry;
  final bool isMe;
  final int staggerIndex;

  @override
  State<_LeaderboardRow> createState() => _LeaderboardRowState();
}

class _LeaderboardRowState extends State<_LeaderboardRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    Future.delayed(Duration(milliseconds: 40 * widget.staggerIndex), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final change = widget.entry.rankChange;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Opacity(
        opacity: _animation.value,
        child: Transform.translate(
          offset: Offset((1 - _animation.value) * -14, 0),
          child: child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
        decoration: widget.isMe
            ? BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppSpacing.md),
              )
            : null,
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text('${widget.entry.rank}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium),
            ),
            const SizedBox(width: AppSpacing.sm),
            UserAvatar(name: widget.entry.name, radius: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                widget.isMe ? context.l10n.you : widget.entry.name,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(context.l10n.nPts('${widget.entry.points}'), style: theme.textTheme.labelMedium),
            if (change != null && change != 0) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                change > 0 ? '▲$change' : '▼${-change}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: change > 0
                      ? Colors.green.shade600
                      : theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
