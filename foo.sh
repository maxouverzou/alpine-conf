array1="one ONE oNE"
array2="two TWO tWo"

create_xdg_subvolumes() {
	local prefix=$1
    local volume_prefix=@${prefix:1}

    shift

    local my_list=$@

    for volume in $my_list;
    do
        echo $volume_prefix/$volume
    done
}

create_xdg_subvolumes /mnt/test1 $array1
create_xdg_subvolumes /mnt/test2 $array2