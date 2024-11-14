import Testing
import Foundation
@testable import Repositree

struct RepositreeTests {

    @Test
    func testGitHelperWithTransitiveDependencies() async throws {
        // Setup a temporary git repository for testing
        let tempDirURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDirURL, withIntermediateDirectories: true, attributes: nil)
        defer {
            // Clean up the temporary directory after the test
            try? FileManager.default.removeItem(at: tempDirURL)
        }

        let gitHelper = GitHelper(repositoryPath: tempDirURL.path)

        // Initialize git repository
        try gitHelper.runGitCommand("git init")

        // Create and commit the first file
        let file1URL = tempDirURL.appendingPathComponent("file1.txt")
        try "First Commit".write(to: file1URL, atomically: true, encoding: .utf8)
        try gitHelper.runGitCommand("git add .")
        try gitHelper.runGitCommand("git commit -m 'First commit'")

        // Create and commit the second file
        let file2URL = tempDirURL.appendingPathComponent("file2.txt")
        try "Second Commit".write(to: file2URL, atomically: true, encoding: .utf8)
        try gitHelper.runGitCommand("git add .")
        try gitHelper.runGitCommand("git commit -m 'Second commit'")

        // Create and commit the third file
        let file3URL = tempDirURL.appendingPathComponent("file3.txt")
        try "Third Commit".write(to: file3URL, atomically: true, encoding: .utf8)
        try gitHelper.runGitCommand("git add .")
        try gitHelper.runGitCommand("git commit -m 'Third commit'")

        // Get the blob hash of the third file
        let blobHash = try gitHelper.runGitCommand("git hash-object file3.txt").trimmingCharacters(in: .whitespacesAndNewlines)

        // Test getCommits for the third file's blob hash
        let commits = try gitHelper.getCommits(forFileHash: blobHash)

        // Expected: All three commits should be included as transitive dependencies
        #expect(commits.count == 3, "Expected three commits involving the file hash and its ancestors")

        // Verify the order of commits (from latest to earliest)
        #expect(commits[0].message == "Third commit", "Expected the latest commit to be 'Third commit'")
        #expect(commits[1].message == "Second commit", "Expected the parent commit to be 'Second commit'")
        #expect(commits[2].message == "First commit", "Expected the ancestor commit to be 'First commit'")
    }

    @Test
    func testGitHelperWithNoCommits() async throws {
        // Setup a temporary git repository with no commits
        let tempDirURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDirURL, withIntermediateDirectories: true, attributes: nil)
        defer {
            // Clean up the temporary directory after the test
            try? FileManager.default.removeItem(at: tempDirURL)
        }

        let gitHelper = GitHelper(repositoryPath: tempDirURL.path)

        // Initialize git repository
        try gitHelper.runGitCommand("git init")

        // Attempt to get commits for a non-existent blob hash
        let nonExistentBlobHash = "abcdef1234567890abcdef1234567890abcdef12"

        let commits = try gitHelper.getCommits(forFileHash: nonExistentBlobHash)

        // Expected: No commits should be found
        #expect(commits.isEmpty, "Expected no commits involving the non-existent file hash")
    }

    @Test
    func testMermaidGeneratorWithSpecialCharacters() async throws {
        let commit1 = GitCommit(hash: "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0",
                                parents: [],
                                message: "Initial commit with special characters: \"Quotes\", \\Backslashes\\, and \nNewlines")
        let commit2 = GitCommit(hash: "b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1",
                                parents: ["a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0"],
                                message: "Second commit: adding features & improvements")

        let generator = MermaidGenerator(commits: [commit1, commit2])
        let mermaid = generator.generate()

        let expected = """
        graph TD
        a1b2c3d[\"Initial commit with special characters: \\\"Quotes\\\", \\\\Backslashes\\\\, and \\nNewlines\"]
        b2c3d4e[\"Second commit: adding features & improvements\"]
        b2c3d4e --> a1b2c3d
        """

        #expect(mermaid.trimmingCharacters(in: .whitespacesAndNewlines) == expected.trimmingCharacters(in: .whitespacesAndNewlines), "Mermaid output with special characters did not match expected output")
    }

    @Test
    func testMermaidGeneratorWithNoParents() async throws {
        let commit = GitCommit(hash: "c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2",
                               parents: [],
                               message: "Solo commit")

        let generator = MermaidGenerator(commits: [commit])
        let mermaid = generator.generate()

        let expected = """
        graph TD
        c3d4e5f[\"Solo commit\"]
        """

        #expect(mermaid.trimmingCharacters(in: .whitespacesAndNewlines) == expected.trimmingCharacters(in: .whitespacesAndNewlines), "Mermaid output for a solo commit did not match expected output")
    }

    @Test
    func testMermaidGeneratorWithMultipleParents() async throws {
        let commit1 = GitCommit(hash: "d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3",
                                parents: [],
                                message: "Initial commit")
        let commit2 = GitCommit(hash: "e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4",
                                parents: ["d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3"],
                                message: "Feature A")
        let commit3 = GitCommit(hash: "f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5",
                                parents: ["d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3"],
                                message: "Feature B")
        let commit4 = GitCommit(hash: "g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6",
                                parents: ["e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4", "f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5"],
                                message: "Merge Feature A and Feature B")

        let generator = MermaidGenerator(commits: [commit1, commit2, commit3, commit4])
        let mermaid = generator.generate()

        let expected = """
        graph TD
        d4e5f6g[\"Initial commit\"]
        e5f6g7h[\"Feature A\"]
        f6g7h8i[\"Feature B\"]
        g7h8i9j[\"Merge Feature A and Feature B\"]
        e5f6g7h --> d4e5f6g
        f6g7h8i --> d4e5f6g
        g7h8i9j --> e5f6g7h
        g7h8i9j --> f6g7h8i
        """

        #expect(mermaid.trimmingCharacters(in: .whitespacesAndNewlines) == expected.trimmingCharacters(in: .whitespacesAndNewlines), "Mermaid output for merge commits did not match expected output")
    }
}
