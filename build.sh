#!/bin/zsh

copy_file_from_image() {
    image_name=$1
    source_path=$2
    destination_path=$3
    id=$(docker create $image_name)
    docker cp $id:$source_path - > $destination_path
    docker rm -v $id
}

get_unreal_version() {
    carla_version=$1
    [[ $carla_version =~ "0.9.9" ]] && echo '4.24'
    [[ $carla_version =~ "(0.9.8)|(0.9.7)|(0.9.6)" ]] && echo '4.22'
    [[ $carla_version =~ "(0.9.5)|(0.9.4)|(0.9.3)" ]] && echo '4.21'
    [[ $carla_version =~ "(0.9.2)|(0.9.1)|(0.9.0)" ]] && echo '4.19'
    [[ $carla_version =~ "(0.8.4)|(0.8.3)|(0.8.2)|(0.8.1)|(0.8.0)" ]] && echo '4.18'
}
carla_versions=(0.9.9 0.9.8 0.9.7 0.9.6 0.9.5 0.9.4 0.9.3 0.9.2 0.9.1 0.9.0 0.8.4 0.8.3 0.8.2 0.8.1 0.8.0)
for carla_version in $carla_versions
do
    python_versions=(3.5 3.6 3.7)
    for python_version in $python_versions
    do
        docker build \
            --build-arg python_version="$python_version" \
            --build-arg carla_version="$carla_version" \
            --build-arg unreal_engine_version="$(get_unreal_version $carla_version)" \
            --cpu-shares 10 \
            . -t carla_build_docker_image_python_tmp
        mkdir -p carla_"$carla_version"
        if [[ "$carla_version" < "0.9.5" ]]
        then
            source_path="/carla/PythonAPI/dist/carla-"$carla_version"-py"$python_version"-linux-x86_64.egg"
        else
            source_path="/carla/PythonAPI/carla/dist/carla-"$carla_version"-py"$python_version"-linux-x86_64.egg"
        fi
        copy_file_from_image carla_build_docker_image_python_tmp "$source_path" carla_"$carla_version"/carla-"$carla_version"-py"$python_version"-linux-x86_64.egg
    done
done
