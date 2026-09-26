# Reference: https://github.com/arcosoph/nanowakeword?tab=readme-ov-file

def "main prepare" [] {
    print "Initializing the python venv and installing required dependencies..."
    python -m venv .venv
    .venv/bin/pip install scipy==1.14.1 piper-tts nanowakeword[train]

    print "Chaning/Replacing the default resource directory from 'NwwResourcesModel/' to 'resources/nano/'"
    ls ...(glob .venv/lib/*/site-packages/nanowakeword/**/*.py) | get name | each { |file|
        # workarround for changing the default directory for downloaded models.
        open --raw $file | str replace --all "NwwResourcesModel" "resources/nano" | save --raw -f $file
    }

    print "Downloading rhasspy/piper-voices..."
    wget --quiet --directory-prefix resources/nano/tts_models/ https://huggingface.co/rhasspy/piper-voices/resolve/main/pt/pt_BR/cadu/medium/pt_BR-cadu-medium.onnx
    wget --quiet --directory-prefix resources/nano/tts_models/ https://huggingface.co/rhasspy/piper-voices/resolve/main/pt/pt_BR/cadu/medium/pt_BR-cadu-medium.onnx.json

    wget --quiet --directory-prefix resources/nano/tts_models/ https://huggingface.co/rhasspy/piper-voices/resolve/main/pt/pt_BR/faber/medium/pt_BR-faber-medium.onnx
    wget --quiet --directory-prefix resources/nano/tts_models/ https://huggingface.co/rhasspy/piper-voices/resolve/main/pt/pt_BR/faber/medium/pt_BR-faber-medium.onnx.json

    wget --quiet --directory-prefix resources/nano/tts_models/ https://huggingface.co/rhasspy/piper-voices/resolve/main/pt/pt_BR/jeff/medium/pt_BR-jeff-medium.onnx
    wget --quiet --directory-prefix resources/nano/tts_models/ https://huggingface.co/rhasspy/piper-voices/resolve/main/pt/pt_BR/jeff/medium/pt_BR-jeff-medium.onnx.json

    wget --quiet --directory-prefix resources/nano/tts_models/ https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/amy/medium/en_US-amy-medium.onnx
    wget --quiet --directory-prefix resources/nano/tts_models/ https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/amy/medium/en_US-amy-medium.onnx.json

    wget --quiet --directory-prefix resources/nano/tts_models/ https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/kristin/medium/en_US-kristin-medium.onnx
    wget --quiet --directory-prefix resources/nano/tts_models/ https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/kristin/medium/en_US-kristin-medium.onnx.json

    wget --quiet --directory-prefix resources/nano/tts_models/ https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/hfc_female/medium/en_US-hfc_female-medium.onnx
    wget --quiet --directory-prefix resources/nano/tts_models/ https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/hfc_female/medium/en_US-hfc_female-medium.onnx.json

    print "Downloading SonicWeave-v2..."
    wget --quiet --directory-prefix resources/nano/ "https://huggingface.co/datasets/arcosoph/datasets_zip/resolve/main/audio/SonicWeave-v2.zip"
    unzip -q resources/nano/SonicWeave-v2.zip -d training/nano/
}

def "main train" [model --generate_clips --transform_clips --train --all] {
    let config = (cat configs/nano-wakeword_($model)_config.yaml | from yaml)

    if $all or $generate_clips {
        .venv/bin/nanowakeword --config configs/nano-wakeword_($model)_config.yaml --resume training/nano/($model) --generate_clips
    }
    if $all or $transform_clips {
        # Set the OMP_NUM_THREADS and MKL_NUM_THREADS environment variables to 1
        # as a workaround to address the pipeline hanging issue during the data augmentation step.
        with-env { OMP_NUM_THREADS: "1", MKL_NUM_THREADS: "1" } {
                .venv/bin/nanowakeword --config configs/nano-wakeword_($model)_config.yaml --resume training/nano/($model) --transform_clips
        }
    }
    if $all or $train {
        .venv/bin/nanowakeword --config configs/nano-wakeword_($model)_config.yaml --resume training/nano/($model)  --train
    }
}

def "main export" [model] {
    cp training/nano/($model)/model/($model).onnx models/nano-wakeword_($model).onnx
}

def "main clear" [--data --venv --resource --all] {
    if $all or $data {
        rm -rf training/nano
    }
    if $all or $resource {
        rm -rf resources/nano
    }
    if $all or $venv {
        rm -rf .venv
    }
}

def main [] {}
