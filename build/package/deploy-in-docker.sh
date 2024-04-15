#!/bin/sh


bar_size=40
bar_char_done="#"
bar_char_todo="-"
bar_percentage_scale=2


show_progress() {
    current="$1"
    total="$2"

    # calculate the progress in percentage using awk for floating point arithmetic with fixed precision
    percent=$(awk -v current="$current" -v total="$total" \
        'BEGIN {printf "%.2f", (100 * current / total)}')

    # Calculate the number of done and todo characters using awk
    done=$(awk -v percent="$percent" -v bar_size="$bar_size" 'BEGIN {printf "%d", int(bar_size * percent / 100)}')
    todo=$(awk -v done="$done" -v bar_size="$bar_size" 'BEGIN {printf "%d", int(bar_size - done)}')

    # Build the done and todo sub-bars
    done_sub_bar=$(printf "%${done}s" | tr " " "$bar_char_done")
    todo_sub_bar=$(printf "%${todo}s" | tr " " "$bar_char_todo")

    # Output the bar
    printf "\rProgress : [${done_sub_bar}${todo_sub_bar}] ${percent}%%"

    if [ "$total" -eq "$current" ]; then
        printf "\nSuccess: Frontier world deployed\n"
    fi
}


# Default values
rpc_url=""
private_key=""

# Parse command-line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -p1|--rpc-url)
            rpc_url="$2"
            shift 2
            ;;
        -p2|--private-key)
            private_key="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

## Temporarily hardcode private key and rpc url before adding them as params
export RPC_URL="$rpc_url"
export PRIVATE_KEY="$private_key"


show_progress 0 6


#1 Deploying the standard contracts
echo " - Deploying standard contracts..."
pnpm nx run @eve/frontier-standard-contracts:deploy 1> '/dev/null'
wait
show_progress 1 6

export FORWARDER_ADDRESS=$(cat ./standard-contracts/broadcast/Deploy.s.sol/31337/run-latest.json | jq '.transactions|first|.contractAddress' | tr -d \") 

#2 Deploy the world core
echo " - Deploying frontier world..."
pnpm nx deploy @eve/frontier-world-core 1> '/dev/null'
wait
show_progress 2 6

export WORLD_ADDRESS=$(cat ./mud-contracts/core/deploys/31337/latest.json | jq '.worldAddress' | tr -d \")

#3 Configure the world to receive the forwarder
echo " - Configuring trusted forwarder within the world"
pnpm nx setForwarder @eve/frontier-world-core 1> '/dev/null'

wait
show_progress 3 6


#4 Deploy smart object framework 
#
# TODO stop using :local for all the 
echo " - Installing smart object framework into world"
pnpm nx deploy @eve/frontier-smart-object-framework --worldAddress '${WORLD_ADDRESS}' 1> '/dev/null'
show_progress 4 6

#5 Deploy Frontier world features
echo " - Deploying world features"
pnpm nx deploy @eve/frontier-world --worldAddress '${WORLD_ADDRESS}' &> '/dev/null'
show_progress 5 6

echo " - Collecting ABIs"
mkdir abis
mkdir abis/trusted-forwarder
mkdir abis/frontier-world

cp -r standard-contracts/out/ERC2771ForwarderWithHashNonce.sol/ abis/trusted-forwarder
cp -r mud-contracts/frontier-world/out/IWorld.sol/ abis/frontier-world
show_progress 6 6

echo "World address: $WORLD_ADDRESS"
echo "Trusted forwarder address: $FORWARDER_ADDRESS" 
