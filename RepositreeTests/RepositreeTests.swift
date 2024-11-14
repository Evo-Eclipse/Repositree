import Testing
import Foundation
@testable import Repositree


struct RepositreeTests {

    @Test
    func testGitHelper() async throws {
        // Setup a temporary git repository for testing
        let tempDirURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDirURL, withIntermediateDirectories: true, attributes: nil)
        let gitHelper = GitHelper(repositoryPath: tempDirURL.path)

        // Initialize git repository
        try gitHelper.runGitCommand("git init")

        // Create a file and commit
        let testFileURL = tempDirURL.appendingPathComponent("test.txt")
        try "Hello World".write(to: testFileURL, atomically: true, encoding: .utf8)
        try gitHelper.runGitCommand("git add .")
        try gitHelper.runGitCommand("git commit -m 'Initial commit'")

        // Get the blob hash of the file
        let blobHash = try gitHelper.runGitCommand("git hash-object test.txt").trimmingCharacters(in: .whitespacesAndNewlines)

        // Test getCommits
        let commits = try gitHelper.getCommits(forFileHash: blobHash)

        // Use `#expect` to check expected conditions
        #expect(commits.count == 1, "Expected one commit involving the file hash")
        #expect(commits.first?.message == "Initial commit", "Expected commit message to be 'Initial commit'")
    }

    @Test
    func testMermaidGenerator() async throws {
        let commit1 = GitCommit(hash: "a1b2c3d4", parents: [], message: "First commit")
        let commit2 = GitCommit(hash: "d4e5f6g7", parents: ["a1b2c3d4"], message: "Second commit")

        let generator = MermaidGenerator(commits: [commit1, commit2])
        let mermaid = generator.generate()

        let expected = """
        graph TD
        a1b2c3d[\"First commit\"]
        d4e5f6g[\"Second commit\"]
        d4e5f6g --> a1b2c3d
        """

        #expect(mermaid.trimmingCharacters(in: .whitespacesAndNewlines) == expected.trimmingCharacters(in: .whitespacesAndNewlines), "Mermaid output did not match expected output")
    }
}
