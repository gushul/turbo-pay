# README

# Текущая реализация

Код требует улучшений. Большое количество тестов обусловлено необходимостью тщательного тестирования.

## Выбор оптимистичной блокировки

Преимущества выбранного подхода:
- Отсутствие блокировки записей во время выполнения
- Предотвращение дедлоков
- Эффективность при высокой конкуренции и низкой вероятности конфликтов

## TODO

- [ ] Docker и docker-compose конфигурация
- [ ] Реализация кэширования
- [ ] Расширенное логирование
- [ ] Настройка мониторинга и алертинга
- [ ] Документация по развертыванию
- [ ] Добавление индексов (возможно в течение 15 минут)
- [ ] Улучшение безопасности (ограничение запросов по IP)
