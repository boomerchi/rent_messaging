# Talk API

## Tenant

* System General conversation
  - dialogs per message type (info, warning)
  - messages_unread (number)

* Properties
  - 1 landlord conversation per property
  - 1 system conversation per property

## Landlord

* System General conversation
  - dialogs per message type (info, warning)
  - messages_unread (number)

* Owned Properties
  * Property
    * Multiple tenant conversations
    * 1 System conversation
      - dialogs per message type (info, warning, contract)
    * Empty/None conversations (no dialogs started)

    * Property - conversation
      * conversation
        - empty? - no dialogs or messages
        - system?
        - tenant?
        - all_read? - if all dialogs read?
        - any_unread? - !all_read?
        - unread_dialogs_count (number)        
        - unread_dialogs (list of Messages unread)

        - dialogs
        - dialog
            - unread_message_count (number)
            - unread_messages (list of Messages unread)
            - read?
            - unread?

            - messages
              - favorite!
              - delete

Total counters
  Property conversations
    * total of unread_dialogs_count for each property conversation

  System conversations
    * total of unread_dialogs_count for each
