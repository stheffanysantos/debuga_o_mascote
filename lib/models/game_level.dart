/// Interface mínima compartilhada por qualquer fase de qualquer motor de
/// jogo (`Level` do labirinto — Mundos 1/2/3 — e `BlockProgramLevel` de
/// "Programação em Blocos" — Mundo 4, entre outros). Existe só para
/// permitir que `GameWorld.levels` (`lib/models/level.dart`) agrupe fases
/// de motores diferentes sem acoplar `WorldSelectScreen`/`Progress` a um
/// motor específico — as duas únicas operações que o resto do app faz
/// sobre "uma fase de um mundo qualquer" (contar/desbloquear por
/// `Progress.instance`, sempre indexado por `id`) já cabem aqui.
abstract class GameLevel {
  String get id;
}
