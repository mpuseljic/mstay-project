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
        bool[23] amenities;
        uint8 guests;
        uint8 bedrooms;
        uint8 beds;
        uint8 bathrooms;
        bool isActive;
    }

    struct Reservation {
        uint id;
        address guest;
        uint listingId;
        uint checkInDate;
        uint checkOutDate;
        uint totalPrice;
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
    event ListingDeactivated(uint id);
    event ReservationCancelled(uint id);

    // ----------- LISTINGS -----------

    function createListing(
        string memory _title,
        string memory _location,
        string memory _description,
        uint _pricePerNight,
        string[] memory _images,
        bool[23] memory _amenities,
        uint8 _guests,
        uint8 _bedrooms,
        uint8 _beds,
        uint8 _bathrooms
    ) public {
        listingCount++;
        listings[listingCount] = Listing(
            listingCount,
            payable(msg.sender),
            _title,
            _location,
            _description,
            _pricePerNight,
            _images,
            _amenities,
            _guests,
            _bedrooms,
            _beds,
            _bathrooms,
            true
        );

        emit ListingCreated(listingCount, msg.sender, _title);
    }

    function deactivateListing(uint _listingId) public {
        Listing storage listing = listings[_listingId];
        require(listing.owner == msg.sender, "Niste vlasnik oglasa.");
        listing.isActive = false;

        emit ListingDeactivated(_listingId);
    }

    function getAllListings() public view returns (Listing[] memory) {
        uint count = 0;
        for (uint i = 1; i <= listingCount; i++) {
            if (listings[i].isActive) count++;
        }

        Listing[] memory activeListings = new Listing[](count);
        uint index = 0;
        for (uint i = 1; i <= listingCount; i++) {
            if (listings[i].isActive) {
                activeListings[index] = listings[i];
                index++;
            }
        }
        return activeListings;
    }

    function getListingsByOwner(address _owner) public view returns (Listing[] memory) {
        uint count = 0;
        for (uint i = 1; i <= listingCount; i++) {
            if (listings[i].owner == _owner && listings[i].isActive) count++;
        }

        Listing[] memory result = new Listing[](count);
        uint index = 0;
        for (uint i = 1; i <= listingCount; i++) {
            if (listings[i].owner == _owner && listings[i].isActive) {
                result[index] = listings[i];
                index++;
            }
        }
        return result;
    }

    function makeReservation(
        uint _listingId,
        uint _checkInDate,
        uint _checkOutDate
    ) public payable {
        Listing storage listing = listings[_listingId];
        require(listing.owner != address(0), "Oglas ne postoji.");
        require(listing.isActive, "Oglas nije aktivan.");
        require(_checkOutDate > _checkInDate, "Datumi nisu valjani.");

        uint numNights = (_checkOutDate - _checkInDate) / 1 days;
        require(numNights > 0, "Minimalno 1 noc.");
        uint totalPrice = listing.pricePerNight * numNights;
        require(msg.value >= totalPrice, "Nedovoljno ETH.");

        // provjera preklapanja rezervacija
        for (uint i = 1; i <= reservationCount; i++) {
            Reservation memory r = reservations[i];
            if (r.listingId == _listingId) {
                bool overlaps = _checkInDate < r.checkOutDate && _checkOutDate > r.checkInDate;
                require(!overlaps, "Termin je vec zauzet.");
            }
        }

        reservationCount++;
        reservations[reservationCount] = Reservation(
            reservationCount,
            msg.sender,
            _listingId,
            _checkInDate,
            _checkOutDate,
            totalPrice
        );

        listing.owner.transfer(totalPrice);

        emit ReservationMade(reservationCount, msg.sender, _listingId);
    }

    function getReservationsByGuest(address _guest) public view returns (Reservation[] memory) {
        uint count = 0;
        for (uint i = 1; i <= reservationCount; i++) {
            if (reservations[i].guest == _guest) count++;
        }

        Reservation[] memory result = new Reservation[](count);
        uint index = 0;
        for (uint i = 1; i <= reservationCount; i++) {
            if (reservations[i].guest == _guest) {
                result[index] = reservations[i];
                index++;
            }
        }
        return result;
    }

    function cancelReservation(uint _reservationId) public {
        Reservation memory r = reservations[_reservationId];
        require(r.id != 0, "Rezervacija ne postoji.");
        require(r.guest == msg.sender, "Niste vlasnik rezervacije.");

        delete reservations[_reservationId];

        emit ReservationCancelled(_reservationId);
    }

    function getAllReservations() public view returns (Reservation[] memory) {
        Reservation[] memory allReservations = new Reservation[](reservationCount);
        for (uint i = 1; i <= reservationCount; i++) {
            allReservations[i - 1] = reservations[i];
        }
        return allReservations;
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
