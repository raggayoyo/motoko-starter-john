import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import Iter "mo:base/Iter";

actor class StudentWall(){
    var messageId : Nat = 0;
    private func _hashNat(n:Nat) : Hash.Hash = return Text.hash(Nat.toText(n));
    let wall = HashMap.HashMap<Nat, Message>(0, Nat.equal, _hashNat);

//Type Definition

    public type Answer = (
        description : Text, 
        numberOfVotes : Nat 
    );

    public type Survey = {
        title : Text; 
        answers : [Answer]; 
    };

    public type Content = {
        #Text : Text;
        #Image : Blob;
        #Survey : Survey;
    };

    public type Message = {
    vote : Int;
    content : Content;
    creator: Principal;
    };

//ADD NEW MESSAGE
    public shared ({ caller }) func writeMessage(c : Content) : async Nat{
        let id : Nat = messageId;
            messageId += 1;
        let msg : Message = {
            vote = 0;
            content = c;
            creator = caller;
        };
        wall.put(id,msg);
        return id;
    };

//GET MESSAGE
    public shared query func getMessage(messageId : Nat) : async Result.Result<?Message, Text> {
        let msg : ?Message = wall.get(messageId);
        if (msg == null) {
            return #err ("Not Implemented / Out of Index")
        }
        else {
            return #ok(msg);
        }
    };

//UPDATE MESSAGE
    public shared ({ caller }) func updateMessage(messageId : Nat, c : Content) : async Result.Result<(), Text> {
        let validator : ?Message = wall.get(messageId);
        switch(validator){
            case(null){
                return #err("Not Implemented / Out of Index");
            };
            case(?currentMessage){
                if (Principal.equal(currentMessage.creator, caller)){
                    let msg = {
                        vote = currentMessage.vote;
                        content = c;
                        creator = currentMessage.creator;
                    };
                    wall.put(messageId,msg);
                    return #ok();
                }
                else {
                    return #err ("You are not the owner of this message.");
                }
            };
        }
    };

//DELETE MESSAGE
    public shared ({ caller }) func deleteMessage(messageId : Nat) : async Result.Result<(), Text> {
        let msg : ?Message = wall.get(messageId);
        if (msg == null) {
            return #err ("Not Implemented / Out of Index")
        }
        else {
            wall.delete(messageId);
            return #ok();
        }
    };

//UPVOTE MESSAGE
    public func upVote(messageId : Nat) : async Result.Result<(), Text> {
        let msg : ?Message= wall.get(messageId);
        switch(msg) {
            case (null){
                return #err ("Not Implemented / Out of Index")
            };
            case (?currentMessage){
                let new_msg = {
                    vote = currentMessage.vote + 1;
                    content = currentMessage.content;
                    creator = currentMessage.creator;
                };
                wall.put(messageId,new_msg);
                return #ok();
            }

        }
    };

//DOWNVOTE MESSAGE
    public func downVote(messageId : Nat) : async Result.Result<(), Text> {
        let msg : ?Message= wall.get(messageId);
        switch(msg) {
            case (null){
                return #err ("Not Implemented / Out of Index")
            };
            case (?currentMessage){
                let new_msg = {
                    vote = currentMessage.vote - 1;
                    content = currentMessage.content;
                    creator = currentMessage.creator;
                };
                wall.put(messageId,new_msg);
                return #ok();
            }

        }
    };

//GET ALL MESSAGES
    public func getAllMessages() : async [Message] {
        let list = Buffer.Buffer<Message>(0);
        for (value in wall.vals()){
            list.add(value);
        };
        return Buffer.toArray<Message>(list);
    };

//GET ALL MESSAGES RANKED
    public func getAllMessagesRanked() : async [Message] {
        let list = Buffer.Buffer<Message>(0);
        let list2 = Buffer.Buffer<Message>(0);
        
        for (value in wall.vals()){
            list.add(value);
        };

        var j = 0;
        var index = 0;
        var votx : Int = 0;

        while (list.size() > 0) {
            j := 0;
            index := 0;
            votx := list.get(index).vote;
            for (value in list.vals()){
                if (votx < value.vote){
                    index := j;
                    votx := value.vote;
                };
                j += 1;
            };
            list2.add(list.get(index));
            let x = list.remove(index);
        };
        return Buffer.toArray<Message>(list2);
    };
}