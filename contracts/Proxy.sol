// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";

contract Proxy {
    using Address for address;
    using StorageSlot for bytes32;

    // 이 코드는 학습용으로 슬롯을 직접 지정한 예제일 뿐이고,
    // 실무에서는 이미 회사에서 정한 고정된 slot 주소값을 내려줘서 그걸 써야 함
    // 외부에서 값을 주입해주어 지금 이 예시에서처럼 다 보이게 하지 않음 (보안 목적)
    bytes32 private constant IMPLEMENTATION_SLOT =
        bytes32(uint256(keccak256("inbrew.proxy")) - 1);
    bytes32 private constant ADMIN_SLOT =
        bytes32(uint256(keccak256("inbrew.admin")) - 1);

    event AdminTransferred(
        address indexed previousAdmin,
        address indexed newAdmin
    );
    event Upgraded(address indexed oldImpl, address indexed newImpl);

    modifier isContract(address _implementation) {
        require(
            _isContract(_implementation),
            "_newImplementation is not a contract address"
        );
        require(
            _implementation != address(0),
            "_newImplementation can't be a zero address"
        );
        _;
    }

    modifier onlyAdmin() {
        require(getAdmin() == msg.sender, "Caller is not the admin");
        _;
    }

    constructor(address _implementation) isContract(_implementation) {
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = _implementation;
        StorageSlot.getAddressSlot(ADMIN_SLOT).value = msg.sender;
    }

    function _isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function getImplementation() public view returns (address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    function getImplementationSlot() public view onlyAdmin returns (bytes32) {
        return IMPLEMENTATION_SLOT;
    }

    function getAdminSlot() public view onlyAdmin returns (bytes32) {
        return ADMIN_SLOT;
    }

    function getAdmin() public view returns (address) {
        return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
    }

    // delegate call 은 유명한 함수로 쌤도 가져다 쓰심
    function _delegate(address impl) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    receive() external payable {}

    fallback() external payable {
        _delegate(StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value);
    }

    // 투명화 업그레이드 패턴
    function upgrade(
        address newAddress
    ) public onlyAdmin isContract(newAddress) {
        address oldImpl = getImplementation();
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = newAddress;
        emit Upgraded(oldImpl, newAddress);
    }

    function adminTransfer(address newAdmin) public onlyAdmin {
        address oldAdmin = getAdmin();
        StorageSlot.getAddressSlot(ADMIN_SLOT).value = newAdmin;
        emit AdminTransferred(oldAdmin, newAdmin);
    }
}
