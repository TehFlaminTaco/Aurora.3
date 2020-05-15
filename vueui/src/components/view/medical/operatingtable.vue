<template>
  <div>
    <div v-if="has_victim">
      <h3>Patient Information:</h3><br>
      Brain Activity: <span :style="{color:brainLabel(brain_result)}"><b>{{brainText(brain_result)}}</b></span><br>
      Pulse: <b>{{pulse}}</b><br>
      BP: <b>{{bp}}</b><br>
      Blood Oxygenation: <b>{{bloodoxy}}</b><br>
    </div>
    <div v-else>
      <h3>Patient Information:</h3><br><br>
      <b>No Patient Detected</b>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return this.$root.$data.state; // Make data more easily accessible
  },
  methods: {
      brainLabel(value) {
      switch (value) {
        case 0:
          return "Crimson"
        case -1:
          return "LightSkyBlue"
        default:
          if (value <= 50) {
            return "Crimson"
          }
          else if (value <= 80) {
            return "Orange"
          }
          else {
            return "LimeGreen"
          }
        }
      },
    brainText(value) {
      switch (value) {
        case 0:
          return "none, patient is braindead"
        case -1:
          return "ERROR - Nonstandard biology"
        default:
          return value.toString().concat("%");
        }
      },
  }
};
</script>