module hello_sui::hello_world {
    use std::string::{utf8, String};
    use sui::event;

    /// Greeting object that stores a message
    public struct Greeting has key, store {
        id: object::UID,
        message: String,
        creator: address,
    }

    /// Event emitted when greeting is created
    public struct GreetingCreated has copy, drop {
        greeting_id: address,
        message: String,
        creator: address,
    }

    /// Create a new greeting with custom message
    #[allow(lint(self_transfer))]
    public fun create_greeting(
        message_bytes: vector<u8>,
        ctx: &mut tx_context::TxContext
    ) {
        let message = utf8(message_bytes);
        let creator = tx_context::sender(ctx);
        
        let greeting = Greeting {
            id: object::new(ctx),
            message,
            creator,
        };

        let greeting_id = object::uid_to_address(&greeting.id);

        // Emit event
        event::emit(GreetingCreated {
            greeting_id,
            message,
            creator,
        });

        // Transfer to creator
        transfer::public_transfer(greeting, creator);
    }

    /// Get greeting message (read-only)
    public fun get_message(greeting: &Greeting): String {
        greeting.message
    }

    /// Get greeting creator
    public fun get_creator(greeting: &Greeting): address {
        greeting.creator
    }

    /// Update greeting message (only creator)
    public fun update_message(
        greeting: &mut Greeting,
        new_message: vector<u8>,
        ctx: &tx_context::TxContext
    ) {
        assert!(greeting.creator == tx_context::sender(ctx), 0);
        greeting.message = utf8(new_message);
    }

    #[test_only]
    public fun create_greeting_for_testing(
        message_bytes: vector<u8>,
        ctx: &mut tx_context::TxContext
    ): Greeting {
        let message = utf8(message_bytes);
        Greeting {
            id: object::new(ctx),
            message,
            creator: tx_context::sender(ctx),
        }
    }
}