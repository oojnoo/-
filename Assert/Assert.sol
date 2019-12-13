pragma solidity ^0.4.21;

contract Asset {
    address public issuer;
    mapping (address => uint) public balances;
    struct debt{
        address a1;
        address a2;
        uint amount;
    }
    debt[] issuer_debts;
    debt[] others_debts;
    //购买
    event Purchase(string t, address buyer, address seller, uint amount);
    //转让
    event Transfer(string t, address from, address src, address to, uint amount);
    //融资
    event Financing(string t, address src, uint amount);
    //结算
    //event Settle(string t, address from, address to, uint amount);

    constructor() {
        issuer = msg.sender;
    }
    //购买
    function purchase(address buyer, address seller, uint amount) public {
        make_debt(buyer, seller, amount);
        emit Purchase("Purchase", buyer, seller, amount);
    }
    //转让
    function transfer(address from, address src, address to, uint amount) public {
        make_debt(from, src, amount);
        make_debt(src, to, amount);
        emit Transfer("Transfer", from, src, to, amount);
    }
    //融资
    function financing(address src, uint amount) public {
        bool exit;
        uint pos;
        (exit,pos) = is_exit_issure(src);
        if(exit){
            issuer_debts[pos].amount += amount;
        }
        else{
            debt adebt;
            adebt.a1 = src;
            adebt.a2 = issuer;
            adebt.amount = amount;
            issuer_debts.push(adebt);
        }
        emit Financing("Financing", src, amount);
    }
    //结算
    function settle(address from, address to) public {
        uint amount = 0;
        bool exit;
        uint pos;
        if(to == issuer){
            (exit,pos) = is_exit_issure(from);
            if(exit){
                amount = issuer_debts[pos].amount;
            }
        }
        else{
            (exit,pos) = is_exit(from,to);
            if(exit && from == others_debts[pos].a1){
                amount = others_debts[pos].amount;
            }
        }
        emit Purchase("Settle", from, to, amount);
    }
    
    function make_debt(address buyer, address seller, uint amount) public {
        bool exit;
        uint pos;
        (exit,pos) = is_exit(buyer,seller);
        if(exit){
            if(buyer == others_debts[pos].a1)
                others_debts[pos].amount += amount;
            else{
                if(others_debts[pos].amount >= amount){
                    others_debts[pos].amount -= amount;
                }
                else{
                    address a = others_debts[pos].a1;
                    others_debts[pos].a1 = others_debts[pos].a2;
                    others_debts[pos].a2 = a;
                    others_debts[pos].amount = amount - others_debts[pos].amount;
                }
            }
        }
        else{
            debt adebt;
            adebt.a1 = buyer;
            adebt.a2 = seller;
            adebt.amount = amount;
            others_debts.push(adebt);
        }
    }
    
    function is_exit(address buyer,address seller) public returns(bool exit,uint pos) {
        exit = false;
        pos = 0;
        for(uint i = 0;i < others_debts.length;i++){
            if(others_debts[i].a1 == buyer && others_debts[i].a2 == seller){
                exit = true;
                pos = i;
                return (exit,pos);
            }
            if(others_debts[i].a2 == buyer && others_debts[i].a1 == seller){
                exit = true;
                pos = i;
                return (exit,pos);
            }
        }
        return (exit,pos);
    }
    
    function is_exit_issure(address src) public returns(bool exit,uint pos) {
        exit = false;
        pos = 0;
        for(uint i = 0;i < others_debts.length;i++){
            if(others_debts[i].a1 == src){
                exit = true;
                pos = i;
                return (exit,pos);
            }
        }
        return (exit,pos);
    }
}
