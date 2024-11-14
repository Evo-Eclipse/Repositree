import Foundation

let arguments = CommandLine.arguments

if arguments.count != 5 {
    print("Usage: Repositree <visualizerPath> <repositoryPath> <outputImagePath> <fileHash>")
    exit(1)
}

let visualizerPath = arguments[1]
let repositoryPath = arguments[2]
let outputImagePath = arguments[3]
let fileHash = arguments[4]

let visualizer = Visualizer(
    visualizerPath: visualizerPath,
    repositoryPath: repositoryPath,
    outputImagePath: outputImagePath,
    fileHash: fileHash
)

do {
    try visualizer.run()
} catch {
    print("Error: \(error.localizedDescription)")
    exit(1)
}
