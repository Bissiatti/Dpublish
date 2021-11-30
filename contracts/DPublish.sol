pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

import "./DpubToken.sol";
import "./PaperToken.sol";
import "./ReviewToken.sol";


contract DPublish {

    address public plublisher;

    DPubToken public token; 

    PaperToken public paperNFT;
    

    struct _plublisherWalet {
        address addr;
        uint amount;
    }

    constructor(){
        plublisher = msg.sender;
        token = new DPubToken();
        paperNFT = new PaperToken();
    }


    enum StatusDoc {unrevised, partial_review, revised}
    

    uint minimunRate = 10000;
    struct PublishDoc {
        address owner;
        string name;
        StatusDoc status;
        string contentLink;
        uint priority;
        uint256 paperID;
    }

    struct walet{
        PublishDoc[] myDocs;
        uint NumberOfDocs;
    }

    mapping (address => uint) private fund;
    mapping(address => walet) private MyRecord;


    function newDoc(string memory _name, string memory _contentLlink, uint amount) public returns(string memory){
        require(amount>minimunRate, "Your payment is insufficient.");
        require(fund[msg.sender] - amount>0, "Your balance is insufficient.");
        bool x = token.transferFrom(msg.sender,plublisher,amount);  
        if (x){

                PublishDoc memory AuxDoc = PublishDoc({
                owner: msg.sender,
                name: _name,
                status: StatusDoc.unrevised,
                contentLink: _contentLlink,
                priority: amount,
                paperID: paperNFT.newID()
            });
            MyRecord[msg.sender].myDocs.push(AuxDoc);
            paperNFT.safeMint(msg.sender, AuxDoc.paperID);
            return("Add a new doc");
        }else{
            return "Error performing the transfer";
        }
    }

    function getDocsPublished(address _address) public view returns(PublishDoc[] memory){

        uint j=0;
        uint i = 0;
        uint len = MyRecord[_address].NumberOfDocs ;

        PublishDoc[] memory aux = new PublishDoc[](len);
        
        for (; j < len; j = j+1) {  
            if (MyRecord[_address].myDocs[j].status == StatusDoc.revised){
                aux[i] = MyRecord[_address].myDocs[j];
            }      
            i = i+1;
        }

        return aux; 

    } 
    

    function revised(PublishDoc memory doc, address reviewer) public returns(bool){
        if(doc.status == StatusDoc.revised){
            return false;
        }
        else {
            bool x = token.transferFrom(plublisher,reviewer,doc.priority*2/5);
            if (doc.status == StatusDoc.unrevised && x){
                doc.status = StatusDoc.partial_review; 
            }else if(doc.status==StatusDoc.partial_review && x){
                doc.status = StatusDoc.revised;
            }
            return x;
        }
    } 


    event Transfer(address indexed from, address indexed to, uint value);

    event NewDoc(string indexed _name,string indexed _contentLlink,int amount);

    event Revised(PublishDoc indexed _doc, address _reviewer);

    event GetDocsPublished(address indexed _address);

}