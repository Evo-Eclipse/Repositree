import Foundation

class MermaidGenerator {
    let commits: [GitCommit]

    init(commits: [GitCommit]) {
        self.commits = commits
    }

    func generate() -> String {
        var lines: [String] = ["graph TD"]
        var commitMap: [String: GitCommit] = [:]

        // Map commits by their hash for quick lookup
        for commit in commits {
            commitMap[commit.hash] = commit
        }

        // Generate nodes and edges
        for commit in commits {
            let node = "\(commit.shortHash)[\"\(commit.message)\"]"
            lines.append(node)

            // Add edges to parent commits if they are in the list
            for parentHash in commit.parents {
                if commitMap[parentHash] != nil {
                    let edge = "\(commit.shortHash) --> \(String(parentHash.prefix(7)))"
                    lines.append(edge)
                }
            }
        }

        return lines.joined(separator: "\n")
    }
}
