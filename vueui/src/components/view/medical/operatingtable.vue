<template>
  <div>
    <div class="status">
      <div v-if="has_victim">
        <h3>Patient Information:</h3>
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
    <hr>
    <div>
      <div v-if="editor.active" class="simulator">
        <h3>Hologram Parameters:</h3>
        <vui-button v-if="has_victim" :params="{regenerate: 1}">Regenerate</vui-button><br>
        Species: <vui-button :params="{setspecies: 1}">{{editor.species}}</vui-button><vui-button :params="{setsubspecies: 1}">{{editor.subspecies}}</vui-button><br>
        Gender: <vui-button :params="{setgender: 1}">{{editor.gender}}</vui-button><br>
      </div>
      <div v-else>
        <vui-button v-if="!has_victim" class="center" :params="{startholo: 1}">Begin Simulation</vui-button>
      </div>
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

<style lang="scss" scoped>
  .status {
    margin: 1%;
    padding: 10px;
    outline-style: ridge;
    outline-color: green;
    background-color: black;
    height: 130px;
    overflow: auto;
  }
  .simulator {
    margin: 1%;
    padding: 10px;
    outline-style: ridge;
    outline-color: green;
    background-color: black;
    overflow: auto;
  }
</style>