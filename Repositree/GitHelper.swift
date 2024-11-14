import Foundation

struct GitCommit {
    let hash: String
    let parents: [String]
    let message: String

    var shortHash: String {
        return String(hash.prefix(7))
    }
}

class GitHelper {
    let repositoryPath: String

    init(repositoryPath: String) {
        self.repositoryPath = repositoryPath
    }

    func getCommits(forFileHash fileHash: String) throws -> [GitCommit] {
        // Step 1: Get commits that involve the specified file hash
        let command = "git log --pretty=format:\"%H|%P|%s\" --all --find-object=\(fileHash)"
        let initialOutput = try runGitCommand(command)

        var commits: [GitCommit] = []
        var commitHashes: Set<String> = []
        var queue: [String] = []

        // Parse initial commits
        let initialLines = initialOutput.components(separatedBy: "\n")
        for line in initialLines {
            let components = line.components(separatedBy: "|")
            if components.count >= 3 {
                let hash = components[0]
                let parents = components[1].components(separatedBy: " ").filter { !$0.isEmpty }
                let message = components[2]
                let commit = GitCommit(hash: hash, parents: parents, message: message)
                commits.append(commit)
                commitHashes.insert(hash)
                queue.append(contentsOf: parents)
            }
        }

        // Step 2: Traverse ancestors to include transitive dependencies
        while !queue.isEmpty {
            let currentHash = queue.removeFirst()
            if commitHashes.contains(currentHash) {
                continue // Already processed
            }

            // Get commit details
            let ancestorCommand = "git show -s --pretty=format:\"%H|%P|%s\" \(currentHash)"
            let ancestorOutput = try runGitCommand(ancestorCommand)
            let components = ancestorOutput.components(separatedBy: "|")
            if components.count >= 3 {
                let hash = components[0]
                let parents = components[1].components(separatedBy: " ").filter { !$0.isEmpty }
                let message = components[2]
                let commit = GitCommit(hash: hash, parents: parents, message: message)
                commits.append(commit)
                commitHashes.insert(hash)
                queue.append(contentsOf: parents)
            }
        }

        return commits
    }

    @discardableResult
    func runGitCommand(_ command: String) throws -> String {
        let process = Process()
        process.currentDirectoryURL = URL(fileURLWithPath: repositoryPath)
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", command]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != 0 {
            let errorData = (process.standardError as? Pipe)?.fileHandleForReading.readDataToEndOfFile()
            let errorMessage = errorData.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
            throw NSError(
                domain: "GitHelperError",
                code: Int(process.terminationStatus),
                userInfo: [NSLocalizedDescriptionKey: errorMessage]
            )
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else {
            throw NSError(
                domain: "GitHelperError",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to read git output"]
            )
        }

        return output
    }
}
