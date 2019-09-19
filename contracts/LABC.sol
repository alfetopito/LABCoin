pragma solidity ^0.5.0;

contract LABC {
    address public owner;
    bytes32 public name = "Leandro's coin";
    bytes32 public symbol = 'LABC';
    uint8 public decimals = 18;
    uint256 public totalSupply = 0;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) allowances;

    event Mint(address _to, uint256 _amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor(uint256 initialAmount) public {
        owner = msg.sender;
        mint(address(this), initialAmount * uint256(10) ** decimals);
    }

    function mint(address _to, uint256 _value) public returns (bool success) {
        require(msg.sender == owner, 'Only owner can mint');

        totalSupply += _value;
        balances[_to] += _value;

        emit Mint(_to, _value);

        return true;
    }

    function delegateOwnership(address _to) public returns (bool success) {
        require(msg.sender == owner, 'Only owner can delegate ownership');
        require(_to != address(0), 'Can only transfer to a valid address');

        owner = _to;

        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), 'Token burning not allowed');
        require(balanceOf(msg.sender) >= _value, 'Insufficient funds');

        balances[msg.sender] = balanceOf(msg.sender) - _value;
        balances[_to] = balanceOf(_to) + _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), 'Token burning not allowed');
        require(balanceOf(_from) >= _value, 'Insufficient funds');
        // not sure this works when it's not set
        require(allowances[_from][msg.sender] >= _value, 'Sender not authorized to withdraw amount from account');

        balances[_from] = balanceOf(_from) - _value;
        balances[_to] = balanceOf(_to) + _value;
        allowances[_from][msg.sender] = allowances[_from][msg.sender] - _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowances[msg.sender][_spender] = allowances[msg.sender][_spender] + _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        require(_owner != address(0), 'Invalid owner address');
        require(_spender != address(0), 'Invalid spender address');
        
        return allowances[_owner][_spender];
    }


}