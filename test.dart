const concreteNouns = [
  "Cardboard",
  "Shampoo",
  "Think",
  "Dart",
  "Avocado",
  "Dent",
  "Lap",
  "race",
  "rain",
  "Wig",
  "Pilot",
  "Zoo",
  "Post Office",
  "Internet",
  "Chess",
  "Puppet",
  "Sunburn",
  "Sleep",
  "Speaker",
  "Cheerleader",
  "Dust",
  "Dream",
  "Sweater",
  "Picnic",
  "Shrink",
  "Leak",
  "Cloak",
  "Bedbug",
  "Firefighter",
  "Charger",
  "Nightmare",
  "Coach",
  "Sneeze",
  "Chef",
  "Comedian",
  "Cupcake",
  "Baker",
  "Facebook",
  "Giant",
  "Diving",
  "Stingray",
  "Song",
  "Bomb",
  "Treasure",
  "Garbage",
  "Park",
  "Pirate",
  "Whistle",
  "State",
  "Baseball",
  "Queen",
  "Photograph",
  "Computer",
  "Hockey",
  "Hot Dog",
  "iPad",
  "Frog",
  "Pinwheel",
  "Cake",
  "Circus",
  "Battery",
  "Cowboy",
  "Password",
  "Bicycle",
  "Skate",
  "Electricity",
  "Thief",
  "Teapot",
  "Deep",
  "Spring",
  "Nature",
  "Bow tie",
  "Light Bulb",
  "Music",
  "Popsicle",
  "Brain",
  "Birthday Cake",
  "Knee",
  "Pineapple",
  "Tusk",
  "Sprinkler",
  "Money",
  "Pool",
  "Lighthouse",
  "Face",
  "Flute",
  "Rug",
  "Snowball",
  "Purse",
  "Owl",
  "Gate",
  "Suitcase",
  "Stomach",
  "Doghouse",
  "Pajamas",
  "Bathroom",
  "Scale",
  "Peach",
  "Newspaper",
  "Hook",
  "School",
  "French Fries",
  "Beehive",
  "Artist",
  "Flagpole",
  "Camera",
  "Hair Dryer",
  "Mushroom",
  "TV",
  "Quilt",
  "Chalk",
  "Bug",
  "Slide",
  "Swing",
  "Coat",
  "Shoe",
  "Ocean",
  "Dog",
  "Mouth",
  "Milk",
  "Duck",
  "Skateboard",
  "Bird",
  "Mouse",
  "Whale",
  "Jacket",
  "Shirt",
  "Hippo",
  "Beach",
  "Egg",
  "Cookie",
  "Cheese",
  "Skip",
  "Drum",
  "Worm",
  "Spider",
  "Bridge",
  "Bell",
  "Jellyfish",
  "Bunny",
  "Truck",
  "Monkey",
  "Bread",
  "Bracelet",
  "Bat",
  "Clock",
  "Lollipop",
  "Moon",
  "Doll",
  "Basketball",
  "Bike",
  "Seashell",
  "Rocket",
  "Bear",
  "Corn",
  "Chicken",
  "Purse",
  "Glasses",
  "Blocks",
  "Turtle",
  "Horse",
  "Dinosaur",
  "Head",
  "Lamp",
  "Snowman",
  "Ant",
  "Giraffe",
  "Cupcake",
  "Chair",
  "Snail",
  "Baby",
  "Cherry",
  "Crab",
  "Branch",
  "Robot",
  "christmas",
  "santa",
  "money",
  "oreo",
  "patient",
  "director",
  "pendrive",
  "alcohol",
  "police",
  "party",
  "virus",
  "classroom",
  "mobile",
  "passenger",
  "batman",
  "ironman",
  "thanos",
  "bath",
  "throne",
  "elevator",
  "employee",
  "recorder",
  "bus",
  "keyboard",
  "mouse",
  "mother",
  "mirror",
  "refrigerator",
  "singer",
  "tennis",
  "basket",
  "church",
  "clothes",
  "coffee",
  "drawing",
  "hair",
  "ear",
  "nose",
  "mouth",
  "orange",
  "queen",
  "king",
  "signature",
  "song",
  "tooth",
  "vehicle",
  "volume",
  "wife",
  "accident",
  "airport",
  "baseball",
  "girl",
  "hospital",
  "injury",
  "pie",
  "proposal",
  "river",
  "son",
  "speech",
  "tea",
  "warning",
  "winner",
  "writer",
  "chest",
  "chocolate",
  "cookie",
  "drawer",
  "dustbin",
  "honey",
  "honey bee",
  "insect",
  "king",
  "ladder",
  "menu",
  "piano",
  "potato",
  "professor",
  "sister",
  "tongue",
  "wedding",
  "apple",
  "beer",
  "birthday",
  "diamond",
  "friend",
  "hat",
  "moon",
  "pizza",
  "pollution",
  "shirt",
  "surgery",
  "throat",
  "time",
  "film",
  "water",
  "money",
  "fish",
  "hand",
  //till here
  "Apple",
  "Air",
  "Airport",
  "Ambulance",
  "Aircraft",
  "Arrow",
  "Alligator",
  "Ball",
  "Balloon",
  "Bear",
  "Bed",
  "Bow",
  "Bone",
  "Belt",
  "Brain",
  "Buffalo",
  "Bird",
  "Baby",
  "Book",
  "Butter",
  "Bulb",
  "Bat",
  "Bank",
  "Bag",
  "Bus stop",
  "arrow",
  "Bucket",
  "Bow",
  "Bridge",
  "Boat",
  "Car",
  "Cow",
  "Cap",
  "Cooker",
  "Cheese",
  "Crow",
  "Chest",
  "Chair",
  "Candy",
  "Cat",
  "Coffee",
  "Children",
  "Chicken",
  "Church",
  "Chocolate",
  "Clock",
  "Dog",
  "Deer",
  "Donkey",
  "Dolphin",
  "Doctor",
  "Drum",
  "thief",
  "Daughter",
  "Egg",
  "Elephant",
  "Earrings",
  "Ears",
  "Eyes",
  "Finger",
  "Fox",
  "Frog",
  "Fan",
  "Freezer",
  "Fish",
  "Film",
  "Foot",
  "Flag",
  "Factory",
  "Father",
  "Forest",
  "Flower",
  "Fruit",
  "Grapes",
  "Goat",
  "solar system",
  "Gas station",
  "Garage",
  "Gloves",
  "Glasses",
  "Gift",
  "mars",
  "Guitar",
  "Grandmother",
  "Grandfather",
  "Girl",
  "Hamburger",
  "Hand",
  "Head",
  "Hair",
  "Heart",
  "House",
  "Horse",
  "Hen",
  "Horn",
  "Hat",
  "Hammer",
  "Hospital",
  "Jacket",
  "Jumper",
  "Judge",
  "Keyboard",
  "Kangaroo",
  "Knife",
  "Lemon",
  "Lion",
  "Leg",
  "Laptop",
  "suitcase",
  "Lips",
  "Lung",
  "Lighter",
  "Luggage",
  "Lamp",
  "Lawyer",
  "Mouse",
  "Monkey",
  "Mouth",
  "Mango",
  "Mobile",
  "Milk",
  "Music",
  "Mirror",
  "Musician",
  "Mother",
  "Man",
  "Microscope",
  "Newspaper",
  "Nose",
  "Notebook",
  "Neck",
  "Noodles",
  "Nurse",
  "Necklace",
  "Ocean",
  "Ostrich",
  "Orange",
  "Onion",
  "Oven",
  "Owl",
  "Paper",
  "Pant",
  "Palm",
  "Pasta",
  "Pumpkin",
  "Potato",
  "Pencil",
  "Pipe",
  "Police",
  "Pen",
  "Pharmacy",
  "Parrot",
  "aeroplane",
  "Pigeon",
  "Phone",
  "Peacock",
  "Pencil",
  "Pig",
  "Pyramid",
  "Purse",
  "Pancake",
  "Popcorn",
  "Piano",
  "Photographer",
  "Professor",
  "Painter",
  "Park",
  "Plant",
  "Perfume",
  "Radio",
  "Razor",
  "Rainbow",
  "Ring",
  "Rabbit",
  "Rice",
  "Refrigerator",
  "Remote",
  "Restaurant",
  "Road",
  "Shampoo",
  "Sink",
  "Salt",
  "Shark",
  "Sandals",
  "Spoon",
  "Soap",
  "Sand",
  "Sheep",
  "Stomach",
  "Stairs",
  "Soup",
  "Shoes",
  "Scissors",
  "Sparrow",
  "Shirt",
  "Suitcase",
  "Stove",
  "Stairs",
  "Snowman",
  "Shower",
  "Suit",
  "Sweater",
  "Smoke",
  "Sofa",
  "Socks",
  "Stadium",
  "School",
  "Sunglasses",
  "Sandals",
  "Slippers",
  "Shorts",
  "Sandwich",
  "Strawberry",
  "Sister",
  "Son",
  "Singer",
  "Swimming pool",
  "Swim",
  "Star",
  "Sky",
  "Sun",
  "Spoon",
  "Ship",
  "Smile",
  "Table",
  "Tie",
  "Truck",
  "Taxi",
  "Tiger",
  "Tongue",
  "Turtle",
  "Tablet",
  "Train",
  "Toothpaste",
  "Tail",
  "Tea",
  "Tomato",
  "Tunnel",
  "Temple",
  "Toothbrush",
  "Tree",
  "Toy",
  "Tissue",
  "Telephone",
  "Underwear",
  "Umbrella",
  "Villa",
  "Violin",
  "Vase",
  "Wallet",
  "Wolf",
  "Water melon",
  "Whale",
  "Water",
  "Wings",
  "Watch",
  "Washing machine",
  "Wheelchair",
  "Wound",
  "Zebra"
];
