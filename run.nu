def install-papermod-theme [] {
    let version = "7.0"
    let archive = $"hugo-papermod-v($version).tar.gz"

    curl -o $archive -L $"https://github.com/adityatelange/hugo-PaperMod/archive/refs/tags/v($version).tar.gz"
    mkdir themes
    tar -xvf $archive -C themes
    rm -rf $archive
}

def "main build" [] {
    "hello build"
}

def "main provision" [] {
    install-papermod-theme
}

def main [] {}
