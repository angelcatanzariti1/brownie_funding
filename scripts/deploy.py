from brownie import FundMyProject, network, config, MockV3Aggregator
from scripts.helpful_scripts import deploy_mocks, get_account, deploy_mocks
from web3 import Web3

def deploy_fund_me():
    account = get_account()
    # Pass the price feed address to our fundmyproject contract
    # If we are on a persistent network like Rinkeby, use the associated address
    # Otherwise, deploy mocks
    if network.show_active() != "development":
        price_feed_address = config["networks"][network.show_active()][
            "eth_usd_price_feed"
        ]
    else:
        deploy_mocks()
        # Use the most recently deployed MockV3Aggregator
        price_feed_address = MockV3Aggregator[-1].address

    print("Deploying FundMyProject...")
    fund_me = FundMyProject.deploy(
        price_feed_address,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify"),
    )
    print(f"Contract deployed to {fund_me.address}")


def main():
    deploy_fund_me()
