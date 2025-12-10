const Feed = require('../models/Feed');

// Send Feed (Admin)
exports.sendFeed = async (req, res) => {
    try {
        const { farmerId, message } = req.body;

        const feed = new Feed({
            farmerId, // If null, it's for all
            message
        });
        await feed.save();

        // Emit Realtime Event
        const io = req.app.get('io');
        io.emit('new_feed', feed);

        res.status(201).json(feed);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Get Feeds for Farmer
exports.getFeeds = async (req, res) => {
    try {
        const { id } = req.params; // Farmer ID

        // Get messages specifically for this farmer OR broadcast messages (farmerId: null)
        const feeds = await Feed.find({
            $or: [{ farmerId: id }, { farmerId: null }]
        }).sort({ date: -1 });

        res.json(feeds);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
