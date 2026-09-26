# reference: https://github.com/AndreiBulzan/heed-wakeword

def "main prepare" [] {
    print "Initializing the python venv and installing required dependencies..."
    python3 -m venv .venv
    .venv/bin/pip install heed-wakeword[all]
}

def "main train" [model --record --clear] {
    if $clear {
        main clear --data
    }
    let config = (cat configs/heed-wakeword_($model)_config.yaml | from yaml)

    if ($"training/heed/($config.project)" | path exists) == false {
        .venv/bin/heed init training/heed/($config.project) --phrase ($config.phrase)
    }
    .venv/bin/heed download-tts
    .venv/bin/heed download-kokoro
    if $record {
        .venv/bin/heed record training/heed/($config.project) --kind positive --count 15 --duration 2.0
        .venv/bin/heed record training/heed/($config.project) --kind negative --count 15 --duration 2.0
    }
    .venv/bin/heed train training/heed/($config.project) --tts-pos $config.tts-pos --kokoro-pos $config.kokoro-pos
    .venv/bin/heed export training/heed/($config.project)
}

def "main ui" [model] {
    let config = (cat configs/heed-wakeword_($model)_config.yaml | from yaml)

    .venv/bin/heed download-tts
    .venv/bin/heed download-kokoro

    .venv/bin/heed ui --workspace training/heed/($config.project)
}

def "main export" [model] {
    cp training/heed/($model)/export/wake.onnx models/heed-wakeword_($model).onnx
}

def "main clear" [--data --venv --all] {
    if $all or $data {
        rm -rf training/heed
    }
    if $all or $venv {
        rm -rf .venv
    }
}

def main [] {}
