import List "mo:base/List";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";

actor Supplier {
    stable var idCounter : Nat = 0;
    public type MaterialUpdate = {
        materialId : Text; 
        material : Text;
        quantity : Nat;
    };

    type Follower = {
        materialId : Text; 
        callback : shared MaterialUpdate -> ();
    };
    var materials = HashMap.HashMap<Text,(Text,Nat)> (0,Text.equal, Text.hash);
    stable var followers = List.nil<Follower>();
    
    public func createMaterial(material :Text, quantity: Nat): async () {
    let materialid = generateId();
    materials.put(materialid,(material, quantity));
    };
    public query func getMaterial(materialid:Text) : async ?(Text, Nat) {
        materials.get(materialid);
    };
    public query func listMaterial() : async Text {
        var pairs = "";
        for ((key,value) in materials.entries()) {
            let (materialName, quantity) = value;
            pairs := "(" # key # ", " # materialName # ", " # Nat.toText(quantity) # ") \n" # pairs;
        };
        return pairs;
    };
    private func generateId() : Text {
        idCounter += 1;
        return "mat-"#Nat.toText(idCounter);
    };
    public func follow(follower : Follower) {
        followers := List.push(follower, followers);
    };

    public func publishUpdate(update : MaterialUpdate) {
        materials.put(update.materialId,(update.material , update.quantity));
        for (follower in List.toArray(followers).vals()) {
        if (follower.materialId == update.materialId) {
            follower.callback(update);
        };
        };
    };
    public func deleteMaterial(materialId:Text) : () {
        materials.delete(materialId);
    };
};
