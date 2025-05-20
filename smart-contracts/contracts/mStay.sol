// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract mStay {
    struct Listing {
        uint id;
        address payable owner;
        string title;
        string location;
        string description;
        uint pricePerNight;
        string[] images;
    }

    struct Reservation {
        uint id;
        address guest;
        uint listingId;
        uint checkInDate;
        uint checkOutDate;
    }

    struct Review {
    address reviewer;
    uint listingId;
    uint8 rating; // 1–5
    string comment;
}

    uint public listingCount;
    uint public reservationCount;

    mapping(uint => Listing) public listings;
    mapping(uint => Reservation) public reservations;
    mapping(uint => Review[]) public listingReviews;

    event ListingCreated(uint id, address owner, string title);
    event ReservationMade(uint id, address guest, uint listingId);

    function createListing(
        string memory _title,
        string memory _location,
        string memory _description,
        uint _pricePerNight,
        string[] memory _images
    ) public {
        listingCount++;
        listings[listingCount] = Listing(
            listingCount,
            payable(msg.sender),
            _title,
            _location,
            _description,
            _pricePerNight,
            _images
        );

        emit ListingCreated(listingCount, msg.sender, _title);
    }

function getAllListings() public view returns (Listing[] memory) {
    Listing[] memory allListings = new Listing[](listingCount);
    for (uint i = 1; i <= listingCount; i++) {
        allListings[i - 1] = listings[i];
    }
    return allListings;
}




    function makeReservation(
        uint _listingId,
        uint _checkInDate,
        uint _checkOutDate
    ) public payable {
        Listing memory listing = listings[_listingId];
        require(listing.owner != address(0), "Listing does not exist.");
        require(msg.value >= listing.pricePerNight, "Not enough ETH sent.");

        reservationCount++;
        reservations[reservationCount] = Reservation(
            reservationCount,
            msg.sender,
            _listingId,
            _checkInDate,
            _checkOutDate
        );

        listing.owner.transfer(msg.value);

        emit ReservationMade(reservationCount, msg.sender, _listingId);
    }
function getAllReservations() public view returns (Reservation[] memory) {
    Reservation[] memory allReservations = new Reservation[](reservationCount);
    for (uint i = 1; i <= reservationCount; i++) {
        allReservations[i - 1] = reservations[i];
    }
    return allReservations;
}

    function cancelReservation(uint _reservationId) public {
    Reservation memory r = reservations[_reservationId];
    require(r.id != 0, "Rezervacija ne postoji.");
    require(r.guest == msg.sender, "Niste vlasnik rezervacije.");

    delete reservations[_reservationId];
}

function deleteListing(uint _listingId) public {
    Listing storage listing = listings[_listingId];
    require(listing.owner != address(0), "Oglas ne postoji.");
    require(listing.owner == msg.sender, "Niste vlasnik oglasa.");

    delete listings[_listingId];
}


function leaveReview(uint _listingId, uint8 _rating, string memory _comment) public {
    require(_rating >= 1 && _rating <= 5, "Rating mora biti 1-5");
    bool hasReservation = false;

    for (uint i = 1; i <= reservationCount; i++) {
        if (
            reservations[i].listingId == _listingId &&
            reservations[i].guest == msg.sender
        ) {
            hasReservation = true;
            break;
        }
    }

    require(hasReservation, "Niste rezervirali ovaj objekt.");
    listingReviews[_listingId].push(Review(msg.sender, _listingId, _rating, _comment));
}

function getReviewsForListing(uint _listingId) public view returns (Review[] memory) {
    return listingReviews[_listingId];
}


}
