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
        let command = "git log --pretty=format:\"%H|%P|%s\" --all --find-object=\(fileHash)"
        let output = try runGitCommand(command)

        var commits: [GitCommit] = []

        let lines = output.components(separatedBy: "\n")
        for line in lines {
            let components = line.components(separatedBy: "|")
            if components.count >= 3 {
                let hash = components[0]
                let parents = components[1].components(separatedBy: " ").filter { !$0.isEmpty }
                let message = components[2]
                let commit = GitCommit(hash: hash, parents: parents, message: message)
                commits.append(commit)
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
