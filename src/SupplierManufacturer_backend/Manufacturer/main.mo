import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Supplier "canister:supplier";

actor Manufacturer{
    public type MaterialUpdate = {
    materialId : Text;
    material : Text;
    quantity : Nat;
    };
    var materialInventory = HashMap.HashMap<Text, (Text, Nat)>(0, Text.equal, Text.hash);
    public func init(materialId : Text) {
        Supplier.follow({
        materialId = materialId;
        callback = updateInventory;
        });
    };
    public func updateInventory(update : MaterialUpdate){
        let current = materialInventory.get(update.materialId);
        switch(current){
            case(null){
                materialInventory.put(update.materialId,(update.material, update.quantity));
            };
            case(?existing){
                materialInventory.put(update.materialId,(existing.0, existing.1 + update.quantity));
            };
        };
    };
    public query func getInventory() : async [(Text, Text, Nat)] {
    let entriesArray = Iter.toArray<(Text, (Text, Nat))>(materialInventory.entries());
    let inventoryArray = Array.map<(Text, (Text, Nat)), (Text, Text, Nat)>(
        entriesArray,
        func (pair : (Text, (Text, Nat))) : (Text, Text, Nat) {
            let (key, (material, quantity)) = pair;
            return (key, material, quantity);
        }
    );
    return inventoryArray;
    };
};