contract Traceability {

    // Used to log the transfert
    struct Transfert{
        address to;
        uint transfertDate;
    }
    
    struct Entry { // ucfirst for struct and Enums
        address     owner;             // Used to store the current owner wich is capable to act with its entry
        
        string      serial;             // dunno the type, optionnal
        uint        date;               // UNIX Time, optionnal
        // ...add other storage like city or coutry or storeit wherever you like
        
        uint32      nbTransferts;       // Increments transferts (beware to increment this when creating)
        mapping ( uint32 => Transfert) transferts; 
    }
    
    //You can provide a search by bytes32 now :)
    mapping ( bytes32 => Entry ) public entries;
    
    address public admin; // no camelcase nor capital letters for global vars
    
    modifier onlyAdmin() { 
        if (msg.sender != admin) throw;
        _;
    }
    
    modifier noEther() {
        if (msg.value >0) {
            msg.sender.send(msg.value);
        }
        _;
    }
    
    event addedTrack(address _trackAddress, bytes32 _identifier);
    event updatedTrack(address _trackAddress, bytes32 _identifier);

    function Traceability() {
        admin = msg.sender;
    }
    
    /* Add an entry - if don't already exists (ie in entries) - identified by bytes32 (sha3 checksum) */
    function addEntry(string _serial, uint _date, bytes32 _checksum) onlyAdmin noEther {
        if (entries[_checksum].owner != 0) throw; // if the entry already exist, we throw; SFYL;

        Entry e = entries[_checksum]; // maybe a bad thing to checksum a sha3 of a sha3

        e.owner = msg.sender;
        e.serial = _serial;
        e.date = _date;
        e.nbTransferts = 0;
        e.transferts[0] = Transfert({to:msg.sender, transfertDate: now}); //First transfert
        
        addedTrack(msg.sender, _checksum);
    }
    
    /* Change the ownership of a bytes32 */
    function changeOwnership(bytes32 _checksum, address _to) noEther
    {
        if (entries[_checksum].owner == 0) throw; // if the entry don't exists exist, we throw; SFYL;
        if (entries[_checksum].owner != msg.sender) throw; // If the entry doesn't exists, we throw; SFYL;
        
        uint32 _nb = entries[_checksum].nbTransferts++;
        entries[_checksum].transferts[_nb] = Transfert({to:msg.sender, transfertDate: now}); //Following transfert
        updatedTrack(_to, _checksum);
    }
    
    /* Admin can choose a new admin */
    function changeAdmin(address _newAdmin) onlyAdmin noEther
   {
       admin = _newAdmin;
   }

    /* Killcontract */
    function kill() onlyAdmin { 
        selfdestruct(admin);
    }
    
    
}
