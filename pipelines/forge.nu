# reference: https://github.com/H-Ali13381/wakeword-forge/tree/main

def "main prepare" [] {
    print "Initializing the python venv and installing required dependencies..."

    if ("resources/wakeword-forge" | path exists) == false {
        git clone https://github.com/H-Ali13381/wakeword-forge.git resources/wakeword-forge
    }
    python -m venv ./resources/wakeword-forge/.venv
    make --directory=resources/wakeword-forge install-qwentts
}

def "main train-wizard" [model] {
    print "Initializing the python venv and installing required dependencies..."

    let config = (cat configs/forge-wakeword_($model)_config.yaml | from yaml)

    let relative_dir = (pwd)
    make --directory=resources/wakeword-forge cli-run DIR=($relative_dir)/training/forge/($config.project)
}

def "main ui" [model] {
    let config = (cat configs/forge-wakeword_($model)_config.yaml | from yaml)

    let relative_dir = (pwd)
    make --directory=resources/wakeword-forge start DIR=($relative_dir)/training/forge/($config.project)
}

def "main export" [model] {
    cp training/forge/($model)/output/wakeword.onnx models/forge-wakeword_($model).onnx
    cp training/forge/($model)/output/wakeword.json models/forge-wakeword_($model).json
}

def "main clear" [--data --venv --resource --all] {
    if $all or $data {
        rm -rf training/forge
    }
    if $all or $resource {
        rm -rf resources/wakeword-forge
    }
    if $all or $venv {
        rm -rf .venv
    }
}

def main [] {}
