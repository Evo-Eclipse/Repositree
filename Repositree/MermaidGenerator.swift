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

        // First, generate all nodes
        for commit in commits {
            let escapedMessage = escapeMermaidText(commit.message)
            let node = "\(commit.shortHash)[\"\(escapedMessage)\"]"
            lines.append(node)
        }

        // Then, generate all edges
        for commit in commits {
            for parentHash in commit.parents {
                if commitMap[parentHash] != nil {
                    let parentShortHash = String(parentHash.prefix(7))
                    let edge = "\(commit.shortHash) --> \(parentShortHash)"
                    lines.append(edge)
                }
            }
        }

        return lines.joined(separator: "\n")
    }


    private func escapeMermaidText(_ text: String) -> String {
        var escaped = text
        escaped = escaped.replacingOccurrences(of: "\\", with: "\\\\")
        escaped = escaped.replacingOccurrences(of: "\"", with: "\\\"")
        escaped = escaped.replacingOccurrences(of: "\n", with: "\\n")
        return escaped
    }
}
