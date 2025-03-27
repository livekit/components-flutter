/// Possible states for the agent participant
/// These states are set by the agent and sent via LiveKit metadata
enum AgentState {
  initializing, // Agent is starting up
  speaking, // Agent is speaking to the user
  thinking, // Agent is processing user input
  listening; // Agent is listening to user audio

  static AgentState fromString(String value) {
    return AgentState.values.firstWhere(
      (state) => state.name == value,
      orElse: () => AgentState.initializing,
    );
  }
}
