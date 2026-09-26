# reference: https://github.com/livekit/livekit-wakeword

def "main prepare" [] {
    print "Initializing the python venv and installing required dependencies..."
    python3 -m venv .venv
    .venv/bin/pip install onnx livekit-wakeword[train,eval,export,voxcpm]
}

def "main train" [model] {
    .venv/bin/livekit-wakeword setup --config configs/livekit-wakeword_($model)_config.yaml
    .venv/bin/livekit-wakeword run configs/livekit-wakeword_($model)_config.yaml
}

def "main export" [model] {
    cp training/livekit/output/($model)/($model).onnx models/livekit-wakeword_($model).onnx
}

def "main clear" [--data, --output, --venv, --all] {
    if ($all or $data) {
        rm -rf training/livekit/data
    }
    if ($all or $output) {
        rm -rf training/livekit/output
    }
    if ($all or $venv) {
        rm -rf .venv
    }
}

def main [] {}
