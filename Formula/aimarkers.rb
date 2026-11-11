class Aimarkers < Formula
  include Language::Python::Shebang

  desc "Detect AI markers and assess security of code, websites, images and Git repos"
  homepage "https://github.com/z115666/aimarkers"
  # Pinned to a specific commit: immutable, unlike a tag
  url "https://github.com/z115666/aimarkers/archive/f93c900ebb35f6ef533d52cf7a81e8e315325f4a.tar.gz"
  version "1.4.1"
  sha256 "9c732f6c45b7d4ec99c85d58feb511a66f86d15f0a72e1812aa606b22d74ce9a"
  license "MIT"
  head "https://github.com/z115666/aimarkers.git", branch: "main"

  depends_on "python@3.15"

  def install
    libexec.install Dir["aimarkers*.py"], "cvss4.py", "gui"
    rewrite_shebang detected_python_shebang, libexec/"aimarkers.py"
    bin.install_symlink libexec/"aimarkers.py" => "aimarkers"
    doc.install Dir["README*.md", "SECURITY*.md", "CHANGELOG*.md"]
  end

  def caveats
    <<~EOS
      Graphical interface / Interfaz gráfica:
        aimarkers --gui

      To verify C2PA (Content Credentials) signatures in images, also install:
        brew install c2patool
      Para verificar las firmas C2PA de las imágenes, instala también c2patool.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/aimarkers --version")
    assert_match "--gui", shell_output("#{bin}/aimarkers --help")
    assert_path_exists libexec/"gui/index.html"
    system libexec/"aimarkers.py", "--help"

    (testpath/"human.md").write "Notes from yesterday's meeting: check the proxy and close the ticket."
    assert_match "No relevant signs", shell_output("#{bin}/aimarkers #{testpath}/human.md --no-color --lang en")
    assert_match "Sin indicios relevantes", shell_output("#{bin}/aimarkers #{testpath}/human.md --no-color --lang es")

    (testpath/"app.py").write "import requests\nrequests.get('https://example.com', verify=False)\n"
    salida = shell_output("#{bin}/aimarkers #{testpath}/app.py --security-only --no-color --lang en")
    assert_match "TLS verification disabled in code", salida
    assert_match "CVSS:4.0/", salida

    (testpath/"ai.md").write "More information at https://example.com/?utm_source=chatgpt.com"
    assert_match "EXPLICIT ATTRIBUTION", shell_output("#{bin}/aimarkers #{testpath}/ai.md --no-color --lang en")
  end
end
