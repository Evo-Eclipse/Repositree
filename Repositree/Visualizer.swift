import Foundation

struct Visualizer {
    let visualizerPath: String
    let repositoryPath: String
    let outputImagePath: String
    let fileHash: String

    func run() throws {
        // Step 1: Get commits involving the specified file hash and their ancestors
        let gitHelper = GitHelper(repositoryPath: repositoryPath)
        let commits = try gitHelper.getCommits(forFileHash: fileHash)

        // Step 2: Generate Mermaid syntax
        let mermaidGenerator = MermaidGenerator(commits: commits)
        let mermaidSyntax = mermaidGenerator.generate()

        // Step 3: Create a temporary directory
        let tempDirectoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true, attributes: nil)

        defer {
            // Step 7: Clean up temporary directory
            try? FileManager.default.removeItem(at: tempDirectoryURL)
        }

        // Step 4: Save Mermaid syntax to a temporary file within the temp directory
        let tempMermaidFileURL = tempDirectoryURL.appendingPathComponent("graph.mmd")
        try mermaidSyntax.write(to: tempMermaidFileURL, atomically: true, encoding: .utf8)

        // Debugging: Verify that the Mermaid file exists
        print("Temporary Directory: \(tempDirectoryURL.path)")
        print("Mermaid File Exists: \(FileManager.default.fileExists(atPath: tempMermaidFileURL.path))")

        // Step 5: Define the output image path within the temp directory
        let tempOutputImageURL = tempDirectoryURL.appendingPathComponent("output.png")

        // Step 6: Convert Mermaid to PNG using relative paths
        try convertMermaidToPNG(mermaidFile: "graph.mmd", outputImagePath: "output.png", in: tempDirectoryURL.path)

        // Debugging: Verify that the PNG file was created
        print("Output Image Exists: \(FileManager.default.fileExists(atPath: tempOutputImageURL.path))")

        // Step 8: Move the generated PNG to the desired absolute path
        try moveFile(from: tempOutputImageURL.path, to: outputImagePath)

        // Output success message
        print("Dependency graph has been successfully generated at \(outputImagePath)")
    }

    private func convertMermaidToPNG(mermaidFile: String, outputImagePath: String, in directory: String) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: visualizerPath)
        process.arguments = ["-i", mermaidFile, "-o", outputImagePath]
        process.currentDirectoryURL = URL(fileURLWithPath: directory)

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()
        process.waitUntilExit()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8) ?? ""
        let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

        if process.terminationStatus != 0 {
            print("Docker Output: \(output)")
            print("Docker Error: \(errorOutput)")
            throw NSError(
                domain: "VisualizerError",
                code: Int(process.terminationStatus),
                userInfo: [NSLocalizedDescriptionKey: "Failed to generate PNG image"]
            )
        }
    }

    private func moveFile(from sourcePath: String, to destinationPath: String) throws {
        let fileManager = FileManager.default

        // Ensure the destination directory exists
        let destinationURL = URL(fileURLWithPath: destinationPath)
        let destinationDirectory = destinationURL.deletingLastPathComponent()
        try fileManager.createDirectory(at: destinationDirectory, withIntermediateDirectories: true, attributes: nil)

        // Move the file
        try fileManager.moveItem(atPath: sourcePath, toPath: destinationPath)
    }
}
