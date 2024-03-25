import List "mo:base/List";
import Nat "mo:base/Nat";

actor Supplier {
    stable var idCounter : Nat = 0;
    public type MaterialUpdate = {
        materialId : Text; // Adding materialId to uniquely identify materials
        material : Text;
        quantity : Nat;
    };

    type Follower = {
        materialId : Text; // Supplier follows updates based on materialId
        callback : shared MaterialUpdate -> ();
    };

    stable var followers = List.nil<Follower>();
    private func generateRandomId() : Text {
        idCounter += 1;
        return "mat-"#Nat.toText(idCounter); // Using current time for simplicity
    };
    public func follow(follower : Follower) {
        followers := List.push(follower, followers);
    };

    public func publishUpdate(update : MaterialUpdate) {
        for (follower in List.toArray(followers).vals()) {
        if (follower.materialId == update.materialId) {
            follower.callback(update);
        };
        };
    };
};
