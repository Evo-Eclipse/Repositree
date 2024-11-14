# Repositree

## Overview / Обзор

**Repositree** is a command-line tool designed to visualize dependency graphs of Git repositories. It analyzes commits involving a specified file hash and generates a comprehensive dependency graph, including transitive dependencies. The graph is represented using Mermaid syntax and is saved as a PNG image.

**Repositree** — это инструмент командной строки, предназначенный для визуализации графов зависимостей Git-репозиториев. Он анализирует коммиты, связанные с указанным хэшем файла, и генерирует подробный граф зависимостей, включая транзитивные зависимости. Граф представлен с использованием синтаксиса Mermaid и сохраняется в формате PNG.

## Features / Особенности

- **Dependency Analysis / Анализ Зависимостей:**
   - Identifies and visualizes direct and transitive dependencies based on commit history.
   - Идентифицирует и визуализирует прямые и транзитивные зависимости на основе истории коммитов.
- **Mermaid Integration / Интеграция с Mermaid:**
   - Utilizes Mermaid for graph representation, ensuring clear and readable diagrams.
   - Использует Mermaid для представления графов, обеспечивая четкие и понятные диаграммы.
- **Dockerized Mermaid CLI / Docker-контейнер для Mermaid CLI:**
   - Leverages Docker to convert Mermaid syntax to PNG without relying on third-party tools.
   - Использует Docker для конвертации синтаксиса Mermaid в PNG без необходимости сторонних инструментов.
- **Customizable Output / Настраиваемый Вывод:**
   - Allows users to specify input repositories, output image paths, and target file hashes.
   - Позволяет пользователям указывать входные репозитории, пути к выходным изображениям и целевые хэши файлов.

## Prerequisites / Требования

- **Git:** Ensure Git is installed and accessible via the command line. / Убедитесь, что Git установлен и доступен через командную строку.
- **Docker:** Required to run the Mermaid CLI for graph generation. / Требуется для запуска Mermaid CLI для генерации графов.
- **Swift:** Necessary for building and running the Repositree tool. / Необходим для сборки и запуска инструмента Repositree.

## Installation / Установка

1. Clone the Repository / Клонируйте Репозиторий:

```other
git clone https://github.com/yourusername/repositree.git
cd repositree
```

1. Install mermaid-cli container / Установите контейнер mermaid-cli:

```shell
docker pull minlag/mermaid-cli
```

1. Build the Project / Соберите Проект:

```other
swift build -c release
```

1. Ensure `mermaid-docker.sh` is executable / Убедитесь, что `mermaid-docker.sh` Имеет Права на исполнение:

```other
chmod +x Scripts/mermaid-docker.sh
```

## Usage / Использование

Run the `Repositree` tool with the following arguments / Запустите инструмент `Repositree` со следующими аргументами:

```other
./Repositree <visualizerPath> <repositoryPath> <outputImagePath> <fileHash>
```

- `<visualizerPath> / <путь_к_визуализатору>`:
   - Path to the Mermaid Docker script (`mermaid-docker.sh`).
   - Путь к скрипту Docker для Mermaid (`mermaid-docker.sh`).
- `<repositoryPath> / <путь_к_репозиторию>`:
   - Path to the Git repository to analyze.
   - Путь к Git-репозиторию для анализа.
- `<outputImagePath> / <путь_к_изображению>`:
   - Destination path for the generated PNG image.
   - Путь назначения для сгенерированного изображения PNG.
- `<fileHash> / <хэш_файла>`:
   - Specific file hash to focus the dependency analysis.
   - Конкретный хэш файла для фокусировки анализа зависимостей.

**Example / Пример:**

```other
./Repositree \
  /path/to/mermaid-docker.sh \
  /path/to/git-repo \
  /path/to/output.png \
  000d0fbfa1bc34e8e398ca32ad11b147c89011ac
```

## Testing / Тестирование

Run the test suite to ensure everything is functioning correctly / Запустите набор тестов, чтобы убедиться, что всё работает корректно:

```other
swift test
```

## Disclaimer / Ответственность

- This project was developed for academic purposes as part of an assignment. The code is not optimized for production.
- Данный проект создан исключительно в академических целях в рамках выполнения задания. Код не оптимизирован для продакшн-использования.

