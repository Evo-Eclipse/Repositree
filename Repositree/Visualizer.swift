import Foundation

struct Visualizer {
    let visualizerPath: String
    let repositoryPath: String
    let outputImagePath: String
    let fileHash: String

    func run() throws {
        // Step 1: Get commits involving the specified file hash
        let gitHelper = GitHelper(repositoryPath: repositoryPath)
        let commits = try gitHelper.getCommits(forFileHash: fileHash)

        // Step 2: Generate Mermaid syntax
        let mermaidGenerator = MermaidGenerator(commits: commits)
        let mermaidSyntax = mermaidGenerator.generate()

        // Step 3: Save Mermaid syntax to a temporary file
        let tempMermaidFile = "\(UUID().uuidString).mmd"
        try mermaidSyntax.write(toFile: tempMermaidFile, atomically: true, encoding: .utf8)

        // Step 4: Convert Mermaid to PNG with a relative output path
        let relativeOutputImagePath = "output.png" // Relative to mounted /data directory
        try convertMermaidToPNG(mermaidFile: tempMermaidFile, outputImagePath: relativeOutputImagePath)

        // Step 5: Move the generated PNG to the desired absolute path
        let fileManager = FileManager.default
        let currentDirectory = fileManager.currentDirectoryPath
        let generatedImagePath = "\(currentDirectory)/\(relativeOutputImagePath)"
        try fileManager.moveItem(atPath: generatedImagePath, toPath: outputImagePath)

        // Output success message
        print("Dependency graph has been successfully generated at \(outputImagePath)")
    }

    private func convertMermaidToPNG(mermaidFile: String, outputImagePath: String) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: visualizerPath)
        process.arguments = ["-i", mermaidFile, "-o", outputImagePath]

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != 0 {
            throw NSError(
                domain: "VisualizerError",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to generate PNG image"]
            )
        }
    }
}

